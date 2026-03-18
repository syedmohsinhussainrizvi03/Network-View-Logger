# Publishing networklogger to pub.dev

This guide walks you through preparing the package for pub.dev, adding screenshots, and publishing.

## Quick deploy (screenshots already added)

If you've already added screenshots to `doc/` and are ready to publish:

1. **Set your repo URLs** in `pubspec.yaml`: replace `your-username` in `homepage`, `repository`, and `issue_tracker` with your GitHub (or other) username and repo name.
2. **Commit everything**: `git add . && git commit -m "Prepare 1.0.0 for pub.dev"`
3. **Dry run**: `dart pub publish --dry-run`
4. **Publish**: `dart pub publish` (sign in with Google when prompted, then confirm with `y`).

Your package will be live at `https://pub.dev/packages/networklogger`.

---

## Prerequisites

- Flutter SDK installed.
- A [Google Account](https://support.google.com/accounts/answer/27441) (used to sign in to pub.dev).
- (Optional) A GitHub (or similar) repository for the package, for `homepage` and `repository` in `pubspec.yaml`.

## Step 1: Set your repository URLs

If you use a Git host (e.g. GitHub), update `pubspec.yaml` with your real URLs:

```yaml
homepage: https://github.com/YOUR_USERNAME/networklogger
repository: https://github.com/YOUR_USERNAME/networklogger
issue_tracker: https://github.com/YOUR_USERNAME/networklogger/issues
```

Replace `YOUR_USERNAME` (and repo name if different) with your actual values. If you don’t have a repo yet, create one and push the package, then set these fields.

## Step 2: Add screenshots for the README

Screenshots make the pub.dev page clearer. The main README references two images in the `doc/` folder.

### 2.1 Run the example app

From the package root:

```bash
cd example
flutter run
```

Choose a device (e.g. simulator or Chrome).

### 2.2 Generate some logs

1. Tap **Send REST request** (this will call httpbin.org and log the request).
2. Tap **Log SDK event** (this logs a sample Amplitude-style event).
3. Tap **Open network logs** to open the log viewer.

### 2.3 Capture screenshots

1. **Log list**  
   With the log viewer open and at least one entry visible, take a screenshot.  
   Save it as **`doc/screenshot_log_list.png`** (relative to the package root).

2. **GraphQL / expanded entry**  
   If you have a GraphQL entry, tap it to expand. Otherwise expand any REST or SDK entry.  
   Take a second screenshot showing the expanded content (query, response, or payload).  
   Save it as **`doc/screenshot_graphql_detail.png`**.

Screenshots are typically:

- **PNG** (or JPEG).
- **Reasonable size** (e.g. 300–800 px wide for readability on pub.dev).

Place both files in the `doc/` folder:

```
networklogger/
  doc/
    README.md
    screenshot_log_list.png      ← add this
    screenshot_graphql_detail.png ← add this
```

The main [README.md](README.md) already references these paths, so they will appear on the package page once you publish.

### 2.4 If you don’t add screenshots

If you publish without adding the image files, the README will show broken image links. You can either:

- Add the two screenshots as above, or  
- Remove or comment out the “Screenshots” section in README.md (the table with `![...](doc/...)`).

## Step 3: Dry run (test publish)

From the **package root** (not `example/`):

```bash
dart pub publish --dry-run
```

This will:

- Validate `pubspec.yaml` and package layout.
- List every file that would be uploaded.
- Report any warnings.

Fix any errors or unwanted files (e.g. add paths to `.gitignore` or `.pubignore`). Common checks:

- **LICENSE** file exists (required).
- No large or sensitive files are included.
- `description` in `pubspec.yaml` is under 180 characters.

## Step 4: Publish to pub.dev

When the dry run looks good:

1. **Commit your changes**  
   Pub recommends a clean Git state (no uncommitted changes) when publishing.

2. **Publish:**

   ```bash
   dart pub publish
   ```

3. **Confirm**  
   You’ll see the list of files again and be asked to confirm. Type `y` and press Enter.

4. **Sign in**  
   If prompted, sign in with your Google Account. Follow the browser flow to authorize pub.dev.

5. **Done**  
   After a successful upload, your package will be available at:

   `https://pub.dev/packages/networklogger`

## Step 5: After publishing

- **Version:** To release updates, bump `version` in `pubspec.yaml` (e.g. to `1.0.1`), update [CHANGELOG.md](CHANGELOG.md), then run `dart pub publish` again.
- **Verified publisher:** You can create a [verified publisher](https://pub.dev/help/verified-publishers) and transfer the package to it so the pub.dev page shows a verified badge and uses your domain.
- **Documentation:** The “Documentation” tab on pub.dev is generated from your Dart doc comments and the package structure; keep the public API well documented.

## Quick checklist

- [ ] Set `homepage`, `repository`, and `issue_tracker` in `pubspec.yaml` (or remove if you don’t use them).
- [ ] Add `doc/screenshot_log_list.png` and `doc/screenshot_graphql_detail.png` (or remove the screenshot section from README).
- [ ] Ensure a `LICENSE` file exists at the package root and contains your chosen license (e.g. BSD-3-Clause). Replace the default placeholder if needed.
- [ ] Run `dart pub publish --dry-run` and fix any issues.
- [ ] Commit all changes.
- [ ] Run `dart pub publish` and complete the sign-in flow.

For more detail, see the official guide: [Publishing packages](https://dart.dev/tools/pub/publishing).
