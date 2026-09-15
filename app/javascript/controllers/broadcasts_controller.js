import { Controller } from "@hotwired/stimulus"
import { SegmentedMessage } from "sms-segments-calculator"

// Connects to data-controller="broadcasts"
export default class extends Controller {
  static targets = [
    "channelInput",
    "audioFileInput",
    "messageInput",
    "beneficiaryGroupsInput",
    "beneficiaryFiltersContainer",
  ]
  static values = {
    messageSegmentWarningThreshold: Number,
    characterCountTranslations: Object,
    deliverableChannels: Array,
    audioChannels: Array,
    textChannels: Array,
  }

  connect() {
    this.toggleChannel()
    this.updateMessageInfo()
  }

  updateMessageInfo() {
    this.#updateCharacterCount()
    this.#checkSegments()
  }

  toggleChannel() {
    const selectedChannel = this.channelInputTarget.value
    const isAudio = this.audioChannelsValue.includes(selectedChannel)
    const isText = this.textChannelsValue.includes(selectedChannel)
    const isDeliverable =
      this.deliverableChannelsValue.includes(selectedChannel)

    this.#toggleInput(this.audioFileInputTarget, isAudio)
    this.#toggleInput(this.messageInputTarget, isText)
    this.#toggleInput(this.beneficiaryGroupsInputTarget, isDeliverable)
    this.#toggleContainer(this.beneficiaryFiltersContainerTarget, isDeliverable)
  }

  #updateCharacterCount() {
    const input = this.#getInputTarget(this.messageInputTarget)
    const infoTarget = this.#getInfoTarget(this.messageInputTarget)

    const count = input.value.length
    const formattedCount = new Intl.NumberFormat().format(count)

    const pluralRule = new Intl.PluralRules().select(count)
    const template =
      this.characterCountTranslationsValue[pluralRule] ??
      this.characterCountTranslationsValue.other

    infoTarget.textContent = template.replace("%{count}", formattedCount)
  }

  #checkSegments() {
    const input = this.#getInputTarget(this.messageInputTarget)
    const segmentedMessage = new SegmentedMessage(input.value)
    const warningTarget = this.#getWarningTarget(this.messageInputTarget)

    if (
      segmentedMessage.segmentsCount > this.messageSegmentWarningThresholdValue
    ) {
      warningTarget.style.display = "block"
    } else {
      warningTarget.style.display = "none"
    }
  }

  #toggleInput(wrapperTarget, enable) {
    if (!wrapperTarget) return

    const input = this.#getInputTarget(wrapperTarget)
    if (input) input.disabled = !enable

    wrapperTarget.hidden = !enable
  }

  #toggleContainer(containerTarget, enable) {
    if (!containerTarget) return

    containerTarget.hidden = !enable

    const inputs = containerTarget.querySelectorAll("input, select, textarea")
    inputs.forEach((input) => {
      input.disabled = !enable

      if (enable) {
        input.dispatchEvent(new Event("change", { bubbles: true }))
      }
    })
  }

  #getInputTarget(target) {
    return target.querySelector("input, textarea, select")
  }

  #getWarningTarget(target) {
    return target.querySelector(".input-warning")
  }

  #getInfoTarget(target) {
    return target.querySelector(".input-info span")
  }
}
