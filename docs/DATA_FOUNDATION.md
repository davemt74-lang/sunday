# Costia Data Foundation

## Purpose

Costia is not a retailer catalog. It is a wellness decision layer that understands:

- what the user wants to improve,
- the concerns connected to that goal,
- the ingredients commonly associated with those goals/concerns,
- the products that contain those ingredients,
- where those products are sold,
- what the user already owns, considered, purchased, stopped, or repurchased,
- and what the user reports over time.

The database intentionally separates **Costia intelligence** from **retailer inventory**.

## Canonical relationship model

```text
User
  -> User Goal
      -> User Concern
          -> Concern -> Ingredient mappings
      -> Goal -> Ingredient mappings

Ingredient
  -> Product Ingredient
      -> Product
          -> Retailer Listing (Costco)
          -> Retailer Listing (CVS)
          -> Retailer Listing (Walgreens)

User
  -> Considering / Saved Products
  -> Cabinet
  -> Check-ins
  -> Learning Progress
  -> Product Events
  -> Provider / Partner Introductions
```

## Why products and retailer listings are separate

A single master product may be sold by multiple retailers with different:

- package counts,
- prices,
- retailer item numbers,
- URLs,
- images,
- and availability.

Costia should not duplicate the product intelligence every time the same product appears at another retailer.

### Example

```text
Master Product
Nature Made Magnesium Glycinate
  -> ingredients
  -> form
  -> Costia goal mappings
  -> Costia concern mappings

Retailer listings
  -> Costco listing: item # / count / price / URL / availability
  -> CVS listing: SKU / count / price / URL / availability
  -> Walgreens listing: SKU / count / price / URL / availability
```

## Recommendation pipeline

Costia recommendations should be generated in stages.

### 1. User relevance

Inputs can include:

- primary goal,
- active concerns,
- desired outcome,
- product format preference,
- monthly budget,
- active Cabinet products,
- previously stopped products,
- saved / considering products,
- user retailer preference,
- prior check-ins.

### 2. Ingredient candidate set

Generate ingredient candidates through:

- `goal_ingredient_map`
- `concern_ingredient_map`

These mappings represent Costia's supplement knowledge graph and are separate from any retailer sponsorship.

### 3. Product candidate set

Products become eligible when their ingredient profile intersects the candidate ingredient set and they meet applicable catalog filters.

Potential ranking components:

- goal relevance,
- concern relevance,
- product-format preference,
- budget fit,
- ingredient overlap / duplication with Cabinet,
- user preference history,
- value per serving,
- retailer availability,
- freshness / quality of product data.

### 4. Retailer listing selection

Once Costia determines that a product is relevant, select the best current retailer listing based on:

- availability,
- package size,
- current price,
- cost per serving,
- user retailer preference,
- listing freshness.

The underlying recommendation remains the same even if the preferred retailer changes.

## Sponsored placements

Sponsored content must be a separate presentation layer.

Do not alter the base Costia Match score because a product or retailer is paying for placement.

Recommended UI model:

```text
Best Match        <- organic Costia ranking
Best Value        <- organic Costia ranking
Alternative       <- organic Costia ranking
Sponsored         <- separately labeled placement
```

## Product lifecycle states

Costia should track user product intent as a lifecycle rather than a single favorite flag.

Suggested states/events:

```text
viewed
saved
considering
retailer_click
purchase_confirmed
cabinet_active
checkin
stopped
completed
repurchased
removed
```

`user_product_events` stores the event history while `user_saved_products` and `user_cabinet` store current state.

## Cabinet intelligence

The Cabinet is more than a list of purchases.

It provides:

- active product inventory,
- ingredient overlap visibility,
- expected supply duration,
- reorder estimation,
- monthly routine cost,
- goal association,
- product start / stop history,
- user-reported outcomes.

This powers Today, Progress, Compare, Simplify My Routine, and reorder logic.

## Today / Home data contract

The Today page should be generated from current state rather than static dashboard cards.

Priority order:

1. urgent or due user action,
2. active primary goal,
3. pending check-in,
4. relevant Cabinet activity,
5. reorder window,
6. contextual learning,
7. new Costia insight,
8. partner introduction if eligibility threshold is reached.

The user should be able to understand the next best action in seconds.

## Contextual learning

`learning_content` replaces the old idea of forcing users into a standalone Academy for every lesson.

Content can attach to:

- goal,
- concern,
- ingredient,
- product,
- shopping concept,
- tracking concept.

Examples:

```text
Sleep Quality -> Why consistency matters
Magnesium -> What are the common forms?
Product -> How to compare serving size and cost/day
Cabinet -> What does ingredient overlap mean?
```

The full guide/library may still expose this content for browsing, but the normal experience is contextual.

## Provider / Partner eligibility

Providers and partners should not be injected randomly.

Possible eligibility inputs:

- active goal age,
- repeated related searches,
- learning engagement,
- products considered,
- product usage history,
- check-in history,
- explicit user request,
- provider-goal relevance.

The user should control what information is shared during an introduction.

## First Costco ingestion pass

For every identifiable supplement / nutrition product in the Costco assortment, capture:

```text
retailer_slug          = costco
retailer_sku           = Costco item number
brand_name
product_name
category_slug
format_slug
canonical_upc          = when available
package_size_label
serving_size_label
servings_per_container
current_price_cents
availability
listing_url
image_url
ingredients_json
last_checked_at
source_notes
```

Then normalize the row into:

- `brands`
- `products`
- `product_ingredients`
- `product_images`
- `retailer_listings`
- `retailer_price_history`

## Image policy

Each master product should ideally have:

1. primary front package image,
2. optional supplement-facts / label image,
3. optional additional package image.

Retailer image URLs may also be stored on the retailer listing because package artwork can differ by retailer or package size.

Production UI should use real catalog images, not AI-generated product packaging.

## Recommended first catalog coverage

Costco first-pass categories:

1. Multivitamins
2. Individual vitamins
3. Minerals
4. Sleep & Relaxation
5. Stress & Mood
6. Energy
7. Brain & Memory
8. Heart Health
9. Digestive & Gut Health
10. Joint & Mobility
11. Sports / Muscle / Recovery
12. Hair / Skin / Nails
13. Immune Support
14. Healthy Aging
15. Women's Wellness
16. Men's Wellness
17. Weight / Metabolic
18. Greens / Superfoods / Herbals

After Costco is complete, CVS and Walgreens become retailer overlays using the same master product / ingredient model.
