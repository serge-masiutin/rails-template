# File Uploads

## Basic Multipart Upload

Use Active Storage through the owning record, Rails forms, and ordinary validation.
Inspect existing attachment models, controllers, and `docs/images.md` before changing
the pipeline. Images are transformed through imgproxy via `.variant(...)`; don't call
`.processed` and introduce local processing just to follow a generic Rails example.

```erb
<%= form_with model: @document do |form| %>
  <%= form.label :attachment %>
  <%= form.file_field :attachment %>
  <%= form.submit t("documents.upload"), data: { turbo_submits_with: t("forms.uploading") } %>
<% end %>
```

File fields make Rails choose multipart encoding. Keep the normal 303/422 contract.
Browser `accept` is a picker hint; validate type, size, count, and ownership server-side.
An upload stream or signed blob ID is external input, not authorization to attach it.

## Backend and Failure Behavior

The feature's model declares the attachment; the controller permits only its named
attribute and authorizes the owning record. Define replacement/deletion semantics
explicitly. If saving fails, preserve ordinary text input; a browser cannot repopulate
a file input from a server path. Tell the user if reselection is necessary.

Do not log filenames/content or signed download URLs as routine request metadata.
Serve private files through the project's authorized route and configured image access
contract. Never make storage public simply to fix a broken preview.

## Multiple Files

Use `multiple: true`, an array-shaped allowed parameter, and a deliberate append/replace
contract. Existing attachments need explicit retained IDs or separate deletion actions;
test that submitting a new file does not silently remove previous ones. Validate a
bounded number and total size, not only each file's size.

```erb
<%= form.file_field :attachments, multiple: true %>
```

For `has_many_attached`, inspect the actual generated hidden field behavior and request
shape in this Rails version. Reject foreign blob/attachment IDs and cover removal,
replacement, empty input, partial failure, and record deletion during upload.

## Image Preview

Use a local object URL for preview; revoke the previous URL on change and on disconnect.
This does not upload the file or validate that the server accepts it.

```javascript
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "image"]

  preview() {
    this.release()
    const file = this.inputTarget.files[0]
    if (!file) {
      this.imageTarget.hidden = true
      this.imageTarget.removeAttribute("src")
      return
    }
    this.objectURL = URL.createObjectURL(file)
    this.imageTarget.src = this.objectURL
    this.imageTarget.hidden = false
  }

  disconnect() {
    this.release()
  }

  release() {
    if (this.objectURL) {
      URL.revokeObjectURL(this.objectURL)
      this.objectURL = null
    }
  }
}
```

The optional object URL represents a documented empty/nonempty lifecycle. Required
Stimulus targets remain strict. Add `turbo:before-cache` cleanup if preview DOM could
be restored after its URL is revoked. Keep the saved attachment preview separate.

## Progress Tracking

Ordinary multipart Turbo submission provides processing state, not upload percentage.
Do not invent `form.progress`. If actual byte progress is required, use the configured
Active Storage direct-upload lifecycle and a labelled progress element:

| Event | UI action |
| --- | --- |
| `direct-upload:initialize` | Allocate one stable entry for the upload ID |
| `direct-upload:start` | Mark uploading |
| `direct-upload:progress` | Set progress from event detail |
| `direct-upload:error` | Show the error, preserve retry/reselect control |
| `direct-upload:end` | Finish that file's UI; record save may still be pending |
| `direct-uploads:end` | Upload batch is ready for form submission |

Direct upload completion and successful attachment to a saved authorized record are
different events. Do not announce a completed document before the form succeeds.
Listen on the actual file input/form; clean up listeners on disconnect.

## Direct Uploads

StarterApp currently does not pin/start `@rails/activestorage` in its importmap/application
entrypoint. `direct_upload: true` alone is insufficient. When this feature is requested,
inspect the installed gem's JS entrypoint, pin the matching asset, start Active Storage
once, configure storage CORS, and test authenticated blob creation and attachment.
Do not add npm/Vite for a dependency Rails already supplies.

Use the server-generated direct-upload URL and CSRF behavior. Recheck record access at
final save. Treat signed blob IDs as identifiers with integrity, not proof of ownership.
Define cleanup for unattached blobs according to the existing retention/storage policy;
do not purge potentially attached files from a browser cancel handler.

## Drag-and-Drop and Programmatic Uploads

Keep a keyboard-accessible file picker as the primary control. A drop zone may assign
selected files or invoke a deliberately configured direct-upload client. Prevent default
only on the drop surface. Validate browser support and file count, display selected
files, and let the user remove one before submit. Do not duplicate the upload by also
submitting raw bytes after creating direct-upload blob IDs.

## Native Verification

Test Android file picker/camera permissions, cancellation, multiple selection, size
limits, background/resume, and attachment errors on a device/emulator when these
behaviors change. Preserve the ordinary HTML form and shared validation. A request
with a Native User-Agent only verifies server presentation.
