# Project Blueprint

## Overview

This document outlines the plan to refactor the application into a fully functional "Offline Mock" app. The goal is to create a high-fidelity prototype with complete UI and simulated backend logic, suitable for user testing and demonstration without requiring a live internet connection.

## Implemented Features (from this refactor)

*   **100% Offline Functionality:** The app will run entirely in a mock environment.
*   **Robust Mock Data:**
    *   A large, realistic dataset for shops, products, and offers.
    *   Corrected geographical data ("الفيوم" instead of "المنوفية").
*   **Full Admin Capabilities (Simulated):**
    *   Admin dashboard with working charts displaying real-time statistics from mock data.
    *   Functional "Add," "Update," and "Delete" operations for shops.
    *   Simulated "Import from Excel" functionality.
*   **Social Media Integration:**
    *   Shop details screen now displays clickable icons for Facebook, Instagram, WhatsApp, and TikTok, allowing users to open dummy social media links.
*   **Voice Search:**
    *   The main search bar now includes a microphone icon, enabling users to perform searches using voice commands.

## Current Refactoring Plan

### Step 1: Add Dependencies
- Add `url_launcher`, `font_awesome_flutter`, and `speech_to_text` to `pubspec.yaml` to enable social media icons and voice search.

### Step 2: Update Data Model (`lib/models/shop.dart`)
- Add `facebookUrl`, `instagramUrl`, `whatsapp`, and `tiktokUrl` fields to the `Shop` model.
- Update `fromMap` and `toMap` methods to include the new fields.

### Step 3: Refactor `api_service.dart`
- **Fix Data Loading:** Ensure `_generateMockData()` is called before any data is accessed to prevent empty screens on launch.
- **Enrich Mock Data:** Expand the mock dataset to over 20 shops per category and correct location data. Add dummy social media URLs.
- **Implement Admin Functions:**
    - `addShop`, `deleteShop`, `updateShop`: Implement CRUD logic on the static `_mockShops` list.
    - `importShopsFromExcel`: Simulate a network delay and return a success message.
    - `getAppStatistics`, `getCategoryChartData`: Calculate and return real statistics based on the mock data.

### Step 4: Enhance Shop Detail UI (`lib/screens/shop_detail_screen.dart`)
- Add a row of social media icons (Facebook, Instagram, WhatsApp, TikTok) using `font_awesome_flutter`.
- Make the icons clickable, launching the corresponding URLs with `url_launcher`.

### Step 5: Implement Voice Search
- Add a microphone icon to the search bar widget (`lib/widgets/search_bar.dart`).
- Use the `speech_to_text` package to listen for user voice input.
- Update the search state in `ShopsProvider` with the recognized text.
