#import "@preview/cetz:0.3.1": canvas, draw
#import "@preview/statastic:1.0.0": arrayLinearRegression, arrayMedian, arrayAvg

#let report(
  title: none,
  course: none,
  authors: (),
  university: none,
  reference: none,
  doc
) = {
  set text(size: 11pt, lang: "fr", font: "New Computer Modern")
  // #set text(size: 11pt, lang: "fr")

  set page(
    numbering: "1",
    margin: (x: 2cm, y: 3cm),
    header: [
      #set text(weight: 400, size: 10pt)
      #stack(dir: ttb, 
        stack(dir: ltr,
          course,
          h(1fr),
          [ #authors.join(" ", last: " & ") ],
        ),
        v(.1cm),
        line(length: 100%, stroke: .4pt)
      )
    ],
    footer: [
      #set text(weight: 400, size: 10pt)
      #stack(dir: ltr,
          university,
          h(1fr),
          [ #context { counter(page).display("1") } ],
          h(1fr),
          reference,
      )
    ],
  )

  set par(justify: true)

  show heading.where(
    level: 2
  ): it => block(width: 100%)[
    #v(0.2cm)
    #set align(center)
    #set text(13pt, weight: 500)
    #smallcaps(it.body)
    #v(0.2cm)
  ]

  show heading.where(
    level: 3
  ): it => text(
    size: 11pt,
    weight: "regular",
    style: "italic",
    it.body + [.],
  )

  align(center)[
    #v(.5cm)
    #rect(inset: .4cm, stroke: .4pt)[
      = #title
    ]
    #v(1cm)
  ]

  show: rest => columns(2, rest)

  doc
}

#let map(val, from_min, from_max, to_min, to_max) = {
  to_min + ((val - from_min) / (from_max - from_min)) * (to_max - to_min)
}

#let inv-value(funct, target-value, epsilon: 0.00001) = {
  if calc.abs(funct(target-value) - target-value) < epsilon {
    return target-value
  }
  
  let low = 0
  let high = target-value * 2
  
  while funct(high) < target-value {
    high = high * 2
  }
  
  for _ in range(50) {
    let mid = (low + high) / 2
    let mid-value = funct(mid)
    
    if calc.abs(mid-value - target-value) < epsilon {
      return mid
    }
    
    if mid-value < target-value {
      low = mid
    } else {
      high = mid
    }
  }
  
  return (low + high) / 2
}

#let load-performance-data(path) = {
  let data = csv(path)
  
  let rows = data.slice(1)
  
  let converted-data = rows.map(row => {
    let size = float(row.at(0))
    let time = float(row.at(1))
    (size, time)
  })
  
  converted-data.map(((size, time)) => (size, time))
}

#let plot-colors = (
  oklch(80%, 40%, 270deg, 100%),
  oklch(75%, 40%, 270deg, 100%),
  oklch(70%, 40%, 270deg, 100%),
  oklch(65%, 40%, 270deg, 100%),
  oklch(60%, 40%, 270deg, 100%),
  oklch(55%, 40%, 270deg, 100%),
  oklch(50%, 40%, 270deg, 100%),
  oklch(45%, 40%, 270deg, 100%),
  oklch(40%, 40%, 270deg, 100%),
  oklch(35%, 40%, 270deg, 100%),
  oklch(30%, 40%, 270deg, 100%),
  oklch(25%, 40%, 270deg, 100%),
  oklch(20%, 40%, 270deg, 100%),
)

#let to-screen(value, min-val, max-val) = {
  if min-val == max-val { return 0 }
  (value - min-val) / (max-val - min-val)
}

#let find-tick-step(min-val, max-val, target-ticks: 10) = {
  let range = max-val - min-val
  let magnitude = calc.pow(10, calc.floor(calc.log(range) / calc.log(10)))
  let possible-steps = (0.1, 0.2, 0.3, 0.5, 1, 2, 5, 10, 20, 50)
  
  for step in possible-steps {
    let scaled-step = step * magnitude
    let num-ticks = calc.ceil(range / scaled-step)
    if num-ticks <= target-ticks {
      return scaled-step
    }
  }
  return possible-steps.last() * magnitude
}

#let format-tick-value(value) = {
  let digits = if calc.abs(value) < 1 {
    2
  } else if calc.abs(value) < 10 {
    1
  } else {
    0
  }
  
  return calc.round(value, digits: digits)
}

#let generate-ticks(min-val, max-val, step) = {
  let start = calc.ceil(min-val / step) * step
  let end = calc.floor(max-val / step) * step
  let ticks = ()
  let current = start
  while current <= end {
    ticks.push(format-tick-value(current))
    current = current + step
  }
  return ticks
}

#let plot-performance-scenario(data) = {
  canvas(length: 5cm, {
    import draw: *

    set-style(
      mark: (fill: black),
      stroke: 0.5pt,
    )

    let scenarios = data.map(el => el.at("scenario"))
                       .dedup()
                       .sorted()
    let projects = data.map(el => el.at("project"))
                      .dedup()
                      .sorted()

    let median-values = ()
    for project in projects {
      let project-data = data.filter(el => el.at("project") == project)
      let project-medians = scenarios.map(s => {
        let values = project-data
          .filter(el => el.at("scenario") == s)
          .map(el => el.at("value"))
        (x: s, y: arrayAvg(values))
      })

      median-values.push(project-medians)
    }

    let median-data = median-values.flatten().map(el => el.at("y"))

    let x-min = scenarios.first()
    let x-max = scenarios.last()
    let y-min = calc.min(..median-data)
    let y-max = calc.max(..median-data)

    let x-ticks = generate-ticks(x-min, x-max, find-tick-step(x-min, x-max))
    let y-ticks = generate-ticks(y-min, y-max, find-tick-step(y-min, y-max))

    line((0, 0), (1.1, 0), mark: (end: "stealth"))
    line((0, 0), (0, 1.1), mark: (end: "stealth"))

    for x in x-ticks {
      if x <= x-max {
        let x-pos = to-screen(x, x-min, x-max)
        line((x-pos, 0), (x-pos, 1), stroke: gray + 0.5pt)
        line((x-pos, 0), (x-pos, -0.02), stroke: black)
        content((x-pos, -0.05), anchor: "north", text(size: 0.5em)[#x])
      }
    }

    for y in y-ticks {
      if y <= y-max {
        let y-pos = to-screen(y, y-min, y-max)
        line((0, y-pos), (1, y-pos), stroke: gray + 0.5pt)
        line((0, y-pos), (-0.02, y-pos), stroke: black)
        content((-0.03, y-pos), anchor: "east", text(size: 0.5em)[#y])
      }
    }

 
    for (project-idx, project-medians) in median-values.enumerate() {
      let project = projects.at(project-idx)
      let color-idx = project-idx
      let color = plot-colors.at(color-idx)
      
      for point in project-medians {
        let x = to-screen(point.x, x-min, x-max)
        let y = to-screen(point.y, y-min, y-max)
        circle((x, y), radius: 0.01, stroke: none, fill: color)
      }
      
      for i in range(1, project-medians.len()) {
        let curr = project-medians.at(i)
        let prev = project-medians.at(i - 1)
        let curr-x = to-screen(curr.x, x-min, x-max)
        let curr-y = to-screen(curr.y, y-min, y-max)
        let prev-x = to-screen(prev.x, x-min, x-max)
        let prev-y = to-screen(prev.y, y-min, y-max)
        line((prev-x, prev-y), (curr-x, curr-y), stroke: color)
      }
    }

    let legend-start = 0.5
    for (i, project) in projects.enumerate() {
      let color-idx = i
      let color = plot-colors.at(color-idx)
      let y-pos = legend-start + (i * 0.06)
      circle((1.1, y-pos), radius: 0.01, stroke: none, fill: color)
      content((1.13, y-pos), text(size: 0.5em)[$p = #project$], anchor: "west")
    }

    content((0.5, -0.1), anchor: "north", text(size: 0.6em)[ Scénario ])

    content((-0.15, 0.5), anchor: "center", angle: 90deg, text(size: 0.6em)[ Temps d'exécution ])
  })
}

#let plot-performance-project(data) = {
  canvas(length: 5cm, {
    import draw: *

    set-style(
      mark: (fill: black),
      stroke: 0.5pt,
    )

    let projects = data.map(el => el.at("project"))
                       .dedup()
                       .sorted()
    let scenarios = data.map(el => el.at("scenario"))
                      .dedup()
                      .sorted()

    let median-values = ()
    for scenario in scenarios {
      let scenario-data = data.filter(el => el.at("scenario") == scenario)
      let scenario-medians = projects.map(s => {
        let values = scenario-data
          .filter(el => el.at("project") == s)
          .map(el => el.at("value"))
        (x: s, y: arrayAvg(values))
      })

      median-values.push(scenario-medians)
    }

    let median-data = median-values.flatten().map(el => el.at("y"))

    let x-min = projects.first()
    let x-max = projects.last()
    let y-min = calc.min(..median-data)
    let y-max = calc.max(..median-data)

    let x-ticks = generate-ticks(x-min, x-max, find-tick-step(x-min, x-max))
    let y-ticks = generate-ticks(y-min, y-max, find-tick-step(y-min, y-max))

    line((0, 0), (1.1, 0), mark: (end: "stealth"))
    line((0, 0), (0, 1.1), mark: (end: "stealth"))

    for x in x-ticks {
      if x <= x-max {
        let x-pos = to-screen(x, x-min, x-max)
        line((x-pos, 0), (x-pos, 1), stroke: gray + 0.5pt)
        line((x-pos, 0), (x-pos, -0.02), stroke: black)
        content((x-pos, -0.05), anchor: "north", text(size: 0.5em)[#x])
      }
    }

    for y in y-ticks {
      if y <= y-max {
        let y-pos = to-screen(y, y-min, y-max)
        line((0, y-pos), (1, y-pos), stroke: gray + 0.5pt)
        line((0, y-pos), (-0.02, y-pos), stroke: black)
        content((-0.03, y-pos), anchor: "east", text(size: 0.5em)[#y])
      }
    }

 
    for (scenario-idx, scenario-medians) in median-values.enumerate() {
      let scenario = scenarios.at(scenario-idx)
      let color-idx = scenario-idx
      let color = plot-colors.at(color-idx)
      
      for point in scenario-medians {
        let x = to-screen(point.x, x-min, x-max)
        let y = to-screen(point.y, y-min, y-max)
        circle((x, y), radius: 0.01, stroke: none, fill: color)
      }
      
      for i in range(1, scenario-medians.len()) {
        let curr = scenario-medians.at(i)
        let prev = scenario-medians.at(i - 1)
        let curr-x = to-screen(curr.x, x-min, x-max)
        let curr-y = to-screen(curr.y, y-min, y-max)
        let prev-x = to-screen(prev.x, x-min, x-max)
        let prev-y = to-screen(prev.y, y-min, y-max)
        line((prev-x, prev-y), (curr-x, curr-y), stroke: color)
      }
    }

    let legend-start = 0.5
    for (i, scenario) in scenarios.enumerate() {
      let color-idx = i
      let color = plot-colors.at(color-idx)
      let y-pos = legend-start + (i * 0.06)
      circle((1.1, y-pos), radius: 0.01, stroke: none, fill: color)
      content((1.13, y-pos), text(size: 0.5em)[$p = #scenario$], anchor: "west")
    }

    content((0.5, -0.1), anchor: "north", text(size: 0.6em)[ Scénario ])

    content((-0.15, 0.5), anchor: "center", angle: 90deg, text(size: 0.6em)[ Temps d'exécution ])
  })
}
