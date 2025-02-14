import gleam/dict.{type Dict}
import gleam/io
import gleam/list
import lustre/element.{type Element}
import lustre/ssg
import website/data/projects
import website/page/about
import website/page/commissions
import website/page/contact
import website/page/index
import website/page/project
import website/page/projects as projects_page

pub fn main() {
  let categories = projects.all()

  let build =
    ssg.new("./priv")
    |> ssg.add_static_route("/", index.view())
    |> ssg.add_static_route("/about", about.view())
    |> ssg.add_static_route("/commissions", commissions.view())
    |> ssg.add_static_route("/contact", contact.view())
    |> ssg.add_static_dir("./static")
    |> ssg.add_static_route("/projects/index", projects_page.view(categories))
    |> add_dynamic_routes(
      categories,
      project.view,
      fn(category: projects.Category) {
        #("/projects/" <> category.path, category.projects)
      },
    )
    |> ssg.build

  case build {
    Ok(_) -> io.println("Build succeeded!")
    Error(e) -> {
      io.debug(e)
      io.println("Build failed!")
    }
  }
}

fn add_dynamic_routes(
  config: ssg.Config(a, b, c),
  list: List(d),
  view: fn(e) -> Element(f),
  map_fn: fn(d) -> #(String, Dict(String, e)),
) -> ssg.Config(a, b, c) {
  use config, element <- list.fold(list, config)
  let #(base, dict) = map_fn(element)
  ssg.add_dynamic_route(config, base, dict, view)
}
