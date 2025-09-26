import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ["replyButton", "replyForm", "cancelReply"];

  connect() {
    console.log("Comments controller connected");
    console.log("Reply buttons found:", this.replyButtonTargets.length);
    console.log("Reply forms found:", this.replyFormTargets.length);

    // Initialize the reply form as hidden
    if (this.hasReplyFormTarget) {
      this.replyFormTarget.style.display = "none";
    }

    this.setupReplyButtons();
    this.setupCancelButtons();
  }

  setupReplyButtons() {
    document.querySelectorAll(".reply-button").forEach((button) => {
      button.addEventListener("click", (event) => {
        const commentId = event.currentTarget.dataset.commentId;
        const form = document.getElementById(`reply-form-${commentId}`);
        if (form) {
          form.style.display = "block";
          form.querySelector("textarea").focus();
        }
      });
    });
  }

  setupCancelButtons() {
    document.querySelectorAll(".cancel-reply").forEach((button) => {
      button.addEventListener("click", (event) => {
        const commentId = event.currentTarget.dataset.commentId;
        const form = document.getElementById(`reply-form-${commentId}`);
        if (form) {
          form.style.display = "none";
          form.querySelector("textarea").value = "";
        }
      });
    });
  }

  toggleReply(event) {
    event.preventDefault();

    if (!this.hasReplyFormTarget) {
      console.error("No reply form found for this comment");
      return;
    }

    // Toggle the form visibility
    const isHidden = this.replyFormTarget.style.display === "none";
    this.replyFormTarget.style.display = isHidden ? "block" : "none";

    // Handle textarea focus and clearing
    const textarea = this.replyFormTarget.querySelector("textarea");
    if (textarea) {
      if (isHidden) {
        textarea.focus();
      } else {
        textarea.value = "";
      }
    }
  }
}
