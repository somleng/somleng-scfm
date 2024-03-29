import { Controller } from "@hotwired/stimulus";
import * as coreui from "@coreui/coreui";

export default class extends Controller {
  static targets = ["sidebar"];

  toggle() {
    coreui.Sidebar.getOrCreateInstance(this.sidebarTarget).toggle();
  }
}
