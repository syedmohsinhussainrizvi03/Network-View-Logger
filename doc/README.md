# Screenshots for pub.dev

Place the following image files in this folder so they appear in the main package README on pub.dev:

1. **screenshot_log_list.png** – Screenshot of the log viewer showing the list of entries (REST, GraphQL, SDK tiles).
2. **screenshot_graphql_detail.png** – Screenshot of an expanded GraphQL entry showing the GraphQL Query and GraphQL Response sections.

## How to capture

1. Run the example app: `cd example && flutter run`.
2. Tap the button to perform a sample request and log an SDK event.
3. Open the log viewer (e.g. tap "Open network logs").
4. Take a screenshot of the list view → save as `screenshot_log_list.png`.
5. Tap a GraphQL (or REST) entry to expand it, then take a screenshot → save as `screenshot_graphql_detail.png`.
6. Copy both files into this `doc/` folder.

If these files are missing, the README will show broken image links until you add them.
