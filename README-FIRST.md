# CONNECT THIS SITE SO EVERY PHONE SEES THE SAME POSTS

This version uses GitHub Pages for the website and Supabase for shared accounts, listings, pictures, messages, reports, and bans.

## 1. Create the free Supabase project

1. Go to Supabase and create a project.
2. Open **SQL Editor**.
3. Open `supabase-setup.sql` from this ZIP.
4. Copy everything from that file into SQL Editor and run it once.

## 2. Connect the website

1. In Supabase, open **Project Settings → API**.
2. Copy the **Project URL**.
3. Copy the **Publishable key** (an anon key also works on older projects).
4. Open `config.js` and replace both placeholder values.
5. Never place a secret key or service-role key in this file.

## 3. Upload to your existing GitHub repository

Replace the old website files with all files from this ZIP. Keep `index.html`, `styles.css`, `script.js`, and `config.js` in the repository root.

## 4. Make your account the administrator

1. Open the live site and register your own account.
2. In Supabase SQL Editor, run the final commented `update` command in `supabase-setup.sql` after replacing the example email with your email.
3. Sign out and sign back in. The **Staff Panel** button will appear.

## What is shared

- Accounts and sign-ins
- Listings posted from phones or computers
- Uploaded listing pictures
- Private messages
- Reports
- Staff bans and listing removals

## Important

Email confirmation may be enabled in Supabase. A new user may need to open the confirmation email before signing in.
