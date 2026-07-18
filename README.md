# West Virginia Sell, Buy, or Trade

This version includes:

- Empty marketplace by default
- User-created listings
- Direct image uploads from phones and computers
- Up to five images per listing
- Search, category filters, and sorting
- Local user profile names
- Private buyer-to-seller messages
- Reports to staff
- Staff panel for banning users, unbanning users, removing listings, and resolving reports
- Mobile-friendly layout

## Staff access

Double-click the **WV logo** at the top-left to open staff login.

Default password:

`WVStaff2026`

Change `STAFF_PASSWORD` near the top of `script.js` before publishing.

## Important GitHub Pages limitation

This is a static GitHub Pages version. Listings, uploaded images, messages, bans, and reports are stored in the current browser using localStorage.

That means:

- Posts made on one device are not automatically visible on another device.
- Staff bans only affect data stored in that browser.
- Clearing browser storage removes the saved marketplace data.

To make it a real shared public marketplace, connect the website to Supabase, Firebase, or another database and image-storage service.

## Publish on GitHub Pages

1. Upload `index.html`, `styles.css`, and `script.js` to the main folder of a public GitHub repository.
2. Open repository **Settings**.
3. Open **Pages**.
4. Select **Deploy from a branch**.
5. Choose `main` and `/root`.
6. Save.
