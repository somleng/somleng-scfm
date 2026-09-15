import { Controller } from "@hotwired/stimulus"
import InspireTree from "inspire-tree"
import InspireTreeDOM from "inspire-tree-dom"

export default class extends Controller {
  static values = {
    data: Array,
    selected: Array,
  }

  connect() {
    this.tree = new InspireTree({
      data: this.dataValue,
      selection: {
        mode: "checkbox",
        disableDirectDeselection: true,
      },
    })

    new InspireTreeDOM(this.tree, {
      target: this.element,
    })

    this.#markChecked()
    this.#hideUnchecked()
  }

  #markChecked() {
    const selectedPaths = new Set(
      this.selectedValue.map((path) => this.#pathKey(path)),
    )

    this.tree.available().each((n) => {
      const node = n.itree.ref
      const originalLabel = node.querySelector("a.title")
      const parent = originalLabel.parentNode

      const label = document.createElement("a")
      label.className = originalLabel.className
      label.innerHTML = originalLabel.innerHTML
      parent.replaceChild(label, originalLabel)

      if (selectedPaths.has(this.#pathKey(n.metadata.path))) {
        n.check()
      }
    })
  }

  #hideUnchecked() {
    this.tree.available().each((n) => {
      const node = n.itree.ref
      const checkbox = node.querySelector('input[type="checkbox"]')

      if (!checkbox.checked && !checkbox.indeterminate) {
        n.hide()
      } else {
        n.expand()
      }

      checkbox.disabled = true
    })
  }

  #pathKey(path) {
    return path.join(".")
  }
}
