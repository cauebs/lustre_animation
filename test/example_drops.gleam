import gleam/dynamic
import gleam/dynamic/decode as d
import gleam/float
import gleam/int
import gleam/list.{filter, map}
import gleam/result
import lustre
import lustre/animation.{type Animator, type Timestamp}
import lustre/attribute.{id, styles}
import lustre/effect.{type Effect}
import lustre/element.{type Element, text}
import lustre/element/html.{div, h3}
import lustre/event

pub type Msg {
  Click(x: Float, y: Float)
  Tick(timestamp: Timestamp)
}

pub type Drop {
  Drop(id: String, x: Float, y: Float, r: Float)
}

pub type Model {
  Model(counter: Int, drops: List(Drop), animations: Animator(String, Float))
}

pub fn main() {
  lustre.application(init, update, render)
  |> lustre.start("#drops", Nil)
}

fn init(_) {
  #(Model(0, [], animation.empty()), effect.none())
}

const to_s = int.to_string

pub fn update(model: Model, msg: Msg) -> #(Model, Effect(Msg)) {
  let m = case msg {
    Click(x, y) -> {
      let id = "drop" <> to_s(model.counter)
      let new_animation = animation.create(with: fn(t) { t }, for: 1500.0)
      let new_drop = Drop(id, x, y, 0.0)
      Model(
        model.counter + 1,
        [new_drop, ..model.drops],
        model.animations |> animation.add(id, new_animation),
      )
    }
    Tick(timestamp) -> {
      let new_animations = animation.tick(model.animations, timestamp)
      let new_drops =
        model.drops
        |> filter(fn(drop) { drop.r != 1.0 })
        |> map(fn(drop) {
          let r =
            animation.value(new_animations, drop.id)
            |> result.unwrap(or: drop.r)
          Drop(..drop, r: r)
        })
      Model(..model, drops: new_drops, animations: new_animations)
    }
  }
  #(m, animation.effect(m.animations, Tick))
}

pub fn render(model: Model) -> Element(Msg) {
  div(
    [
      styles([
        #("width", "100%"),
        #("height", "100%"),
        #("display", "grid"),
        #("grid-template-rows", "auto 1fr"),
      ]),
    ],
    [
      h3([styles([#("text-align", "center")])], [text("Click to make drops")]),
      div(
        [
          id("pond"),
          styles([#("position", "relative")]),
          event.on("mousedown", {
            use x <- d.field("clientX", d.float)
            use y <- d.field("clientY", d.float)
            let rect = bounding_client_rect("pond")
            let assert Ok(#(top, left)) =
              d.run(rect, {
                use top <- d.field("top", d.float)
                use left <- d.field("left", d.float)
                d.success(#(top, left))
              })
            d.success(Click(x -. left, y -. top))
          }),
        ],
        map(model.drops, render_drop),
      ),
    ],
  )
}

fn render_drop(drop: Drop) {
  let r = drop.r *. 50.0
  let rad = float.to_string(r *. 2.0)
  let rw = float.to_string(drop.r *. 2.5)
  let alpha =
    1.0 -. drop.r
    |> float.to_string
  div(
    [
      styles([
        #("position", "absolute"),
        #("left", float.to_string(drop.x -. r) <> "px"),
        #("top", float.to_string(drop.y -. r) <> "px"),
        #("width", rad <> "px"),
        #("height", rad <> "px"),
        #("border", rw <> "px solid rgba(0, 0, 0, " <> alpha <> ")"),
        #("border-radius", "50%"),
      ]),
    ],
    [],
  )
}

@external(javascript, "./info.mjs", "bounding_client_rect")
fn bounding_client_rect(str: String) -> dynamic.Dynamic
