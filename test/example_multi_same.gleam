import lustre
import lustre/animation.{Animations}
import lustre/attribute.{style}
import lustre/cmd.{Cmd}
import lustre/element.{Element, div, h3, text}
import lustre/event.{on}
import gleam/float
import gleam/int
import gleam/list.{filter, map}

pub type Msg {
  Click(x: Float, y: Float)
  Tick(time_offset: Float)
}

pub type Drop {
  Drop(id: String, x: Float, y: Float, r: Float)
}

pub type Model {
  Model(counter: Int, drops: List(Drop), animations: Animations)
}

pub fn main() {
  lustre.application(#(init(), cmd.none()), update, render)
  |> lustre.start("#root")
}

fn init() {
  Model(0, [], animation.new())
}

const to_s = int.to_string

pub fn update(model: Model, msg: Msg) -> #(Model, Cmd(Msg)) {
  let m = case msg {
    Click(x, y) -> {
      let id = "drop" <> to_s(model.counter)
      let new_animations = animation.add(model.animations, id, 0.0, 1.0, 1.5)
      let new_drop = Drop(id, x, y, 0.0)
      Model(model.counter + 1, [new_drop, ..model.drops], new_animations)
    }
    Tick(time_offset) -> {
      let new_animations = animation.tick(model.animations, time_offset)
      let new_drops =
        model.drops
        |> filter(fn(drop) { drop.r != 1.0 })
        |> map(fn(drop) {
          let r = animation.value(new_animations, drop.id, drop.r)
          Drop(..drop, r: r)
        })
      Model(..model, drops: new_drops, animations: new_animations)
    }
  }
  #(m, animation.cmd(m.animations, Tick))
}

pub fn render(model: Model) -> Element(Msg) {
  div(
    [
      style([
        #("height", "100vh"),
        #("display", "grid"),
        #("grid-template-rows", "auto 1fr"),
      ]),
    ],
    [
      h3([style([#("text-align", "center")])], [text("Click to make drops")]),
      div(
        [
          on(
            "mouseDown",
            fn(evt, dispatch) {
              let assert Ok(#(x, y)) = event.mouse_position(evt)
              dispatch(Click(x, y))
            },
          ),
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
  let c =
    drop.r *. 15.0
    |> float.round
    |> int.to_base16()
  let color = "#" <> c <> c <> c
  div(
    [
      style([
        #("position", "absolute "),
        #("left", float.to_string(drop.x -. r) <> "px"),
        #("top", float.to_string(drop.y -. r) <> "px"),
        #("width", rad <> "px"),
        #("height", rad <> "px"),
        #("border", rw <> "px solid " <> color),
        #("border-radius", "50%"),
      ]),
    ],
    [],
  )
}
