This page describes the review process for pull requests in the [windhawk-mods](https://github.com/ramensoftware/windhawk-mods) repository, and what you, as a pull request author, are expected to do.

## Motivation

The mods repository receives many pull requests, and there are limited human resources. To make the most out of the limited reviewer time, the review is split into two stages: an AI review that you run yourself as many times as needed, followed by a human review. The AI review catches the common mistakes early, so that by the time a human reviewer looks at the pull request, only the things that actually need a human are left.

## Labels

Every open pull request carries exactly one of the following labels, which tells everyone whose turn it is:

* **waiting-for-author** - the ball is in your court. Either you haven't requested a review yet, or a review was posted and you need to respond to it.
* **waiting-for-ai-review** - an AI review was requested and is being prepared.
* **waiting-for-reviewer** - the pull request is ready for a human reviewer.

A newly opened pull request is automatically labeled **waiting-for-author**.

## Commands

As the pull request author, you drive the process by posting comments with the following commands:

* `/ai-review` - request an AI review of the current state of the pull request.
* `/ready-for-reviewer` - hand the pull request over to a human reviewer.

## The flow

1. Open the pull request. It gets the **waiting-for-author** label.
2. Comment `/ai-review` and wait for the review to be posted. The pull request is labeled **waiting-for-ai-review** while the review is being prepared, and goes back to **waiting-for-author** once it's posted. Note that it may take a long time (20-30 minutes or more) for the review to be posted.
3. If the review has findings, push the fixes, then comment `/ai-review` again to get a review of the updated code.
4. Repeat step 3 until you're satisfied with the state of the pull request.
5. Comment `/ready-for-reviewer`. The pull request is labeled **waiting-for-reviewer** and enters the queue for a human review.
6. If the human reviewer requests changes, the pull request goes back to **waiting-for-author**, and the process continues from there.

Start with `/ai-review`. Please don't skip straight to `/ready-for-reviewer` - a pull request that hasn't been through an AI review will be sent back.

## Leaving AI comments unaddressed

The AI review isn't always right, and not every finding is worth acting on. If you're using `/ready-for-reviewer` while some AI comments are still unaddressed, explain why in a comment. Common reasons:

* **The AI is wrong** - the finding is based on a misunderstanding of the code or of the way Windhawk works.
* **Out of scope, or not interested** - the finding is about existing code that this pull request doesn't touch, or it's a suggestion you'd rather not follow.
* **Planned for a future version** - the finding is valid, but you prefer to handle it in a later version of the mod.

A short sentence per unaddressed comment is enough. This saves the human reviewer from having to re-investigate findings you already considered.

## Disclaimer

The AI reviewer is set up to look for the mistakes that come up most often in Windhawk mods, but it can still be wrong: it can misread the code, flag correct code as broken, miss real problems, or suggest changes that make things worse. Treat its findings as suggestions to verify, not as instructions to follow blindly. You're responsible for the code you submit - if a finding doesn't hold up, say so instead of changing working code to satisfy it.