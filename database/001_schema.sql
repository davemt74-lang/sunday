-- Costia core relational schema
-- Target: MySQL 8+ / MariaDB 10.6+
-- Purpose: retailer-agnostic supplement intelligence with retailer inventory overlays.

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

CREATE TABLE IF NOT EXISTS users (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(32) NOT NULL DEFAULT 'user',
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  email_verified_at DATETIME NULL,
  last_login_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_users_email (email),
  KEY idx_users_role_status (role, status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_profiles (
  user_id BIGINT UNSIGNED NOT NULL,
  first_name VARCHAR(100) NULL,
  last_name VARCHAR(100) NULL,
  display_name VARCHAR(150) NULL,
  avatar_url VARCHAR(1000) NULL,
  timezone VARCHAR(64) NOT NULL DEFAULT 'America/Phoenix',
  locale VARCHAR(16) NOT NULL DEFAULT 'en-US',
  onboarding_completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_user_profiles_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_preferences (
  user_id BIGINT UNSIGNED NOT NULL,
  monthly_budget_cents INT UNSIGNED NULL,
  preferred_product_format VARCHAR(50) NULL,
  ranking_preference VARCHAR(50) NOT NULL DEFAULT 'best_match',
  preferred_retailer_id BIGINT UNSIGNED NULL,
  notification_checkins TINYINT(1) NOT NULL DEFAULT 1,
  notification_reorders TINYINT(1) NOT NULL DEFAULT 1,
  notification_weekly_briefing TINYINT(1) NOT NULL DEFAULT 1,
  partner_introductions_mode VARCHAR(32) NOT NULL DEFAULT 'ask_first',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id),
  CONSTRAINT fk_user_preferences_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS auth_sessions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  session_token_hash CHAR(64) NOT NULL,
  ip_hash CHAR(64) NULL,
  user_agent VARCHAR(500) NULL,
  expires_at DATETIME NOT NULL,
  last_seen_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_auth_sessions_token (session_token_hash),
  KEY idx_auth_sessions_user (user_id, expires_at),
  CONSTRAINT fk_auth_sessions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wellness_goals (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  code VARCHAR(20) NOT NULL,
  slug VARCHAR(120) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  icon VARCHAR(32) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wellness_goals_code (code),
  UNIQUE KEY uq_wellness_goals_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS wellness_concerns (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  goal_id BIGINT UNSIGNED NOT NULL,
  code VARCHAR(20) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_wellness_concerns_code (code),
  UNIQUE KEY uq_wellness_concerns_slug (slug),
  KEY idx_wellness_concerns_goal (goal_id, sort_order),
  CONSTRAINT fk_wellness_concerns_goal FOREIGN KEY (goal_id) REFERENCES wellness_goals(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS supplement_categories (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  parent_id BIGINT UNSIGNED NULL,
  slug VARCHAR(140) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_supplement_categories_slug (slug),
  KEY idx_supplement_categories_parent (parent_id),
  CONSTRAINT fk_supplement_categories_parent FOREIGN KEY (parent_id) REFERENCES supplement_categories(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ingredients (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(160) NOT NULL,
  name VARCHAR(180) NOT NULL,
  ingredient_type VARCHAR(80) NOT NULL DEFAULT 'other',
  description TEXT NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ingredients_slug (slug),
  KEY idx_ingredients_type (ingredient_type)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS ingredient_forms (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  ingredient_id BIGINT UNSIGNED NOT NULL,
  slug VARCHAR(180) NOT NULL,
  name VARCHAR(180) NOT NULL,
  description TEXT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_ingredient_forms_slug (slug),
  KEY idx_ingredient_forms_ingredient (ingredient_id),
  CONSTRAINT fk_ingredient_forms_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS goal_ingredient_map (
  goal_id BIGINT UNSIGNED NOT NULL,
  ingredient_id BIGINT UNSIGNED NOT NULL,
  relevance_score DECIMAL(5,2) NULL,
  evidence_level VARCHAR(32) NULL,
  notes TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (goal_id, ingredient_id),
  KEY idx_goal_ingredient_ingredient (ingredient_id),
  CONSTRAINT fk_goal_ingredient_goal FOREIGN KEY (goal_id) REFERENCES wellness_goals(id) ON DELETE CASCADE,
  CONSTRAINT fk_goal_ingredient_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS concern_ingredient_map (
  concern_id BIGINT UNSIGNED NOT NULL,
  ingredient_id BIGINT UNSIGNED NOT NULL,
  relevance_score DECIMAL(5,2) NULL,
  evidence_level VARCHAR(32) NULL,
  notes TEXT NULL,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (concern_id, ingredient_id),
  KEY idx_concern_ingredient_ingredient (ingredient_id),
  CONSTRAINT fk_concern_ingredient_concern FOREIGN KEY (concern_id) REFERENCES wellness_concerns(id) ON DELETE CASCADE,
  CONSTRAINT fk_concern_ingredient_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS brands (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(160) NOT NULL,
  name VARCHAR(180) NOT NULL,
  website_url VARCHAR(1000) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_brands_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_formats (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(80) NOT NULL,
  name VARCHAR(100) NOT NULL,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_formats_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  brand_id BIGINT UNSIGNED NULL,
  category_id BIGINT UNSIGNED NULL,
  format_id BIGINT UNSIGNED NULL,
  slug VARCHAR(220) NOT NULL,
  name VARCHAR(255) NOT NULL,
  canonical_upc VARCHAR(32) NULL,
  description TEXT NULL,
  serving_size_label VARCHAR(180) NULL,
  servings_per_container DECIMAL(10,2) NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  source_quality VARCHAR(32) NOT NULL DEFAULT 'unverified',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_products_slug (slug),
  KEY idx_products_brand (brand_id),
  KEY idx_products_category (category_id),
  KEY idx_products_format (format_id),
  CONSTRAINT fk_products_brand FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL,
  CONSTRAINT fk_products_category FOREIGN KEY (category_id) REFERENCES supplement_categories(id) ON DELETE SET NULL,
  CONSTRAINT fk_products_format FOREIGN KEY (format_id) REFERENCES product_formats(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_ingredients (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  ingredient_id BIGINT UNSIGNED NOT NULL,
  ingredient_form_id BIGINT UNSIGNED NULL,
  amount DECIMAL(14,4) NULL,
  unit VARCHAR(30) NULL,
  daily_value_percent DECIMAL(10,2) NULL,
  is_active_ingredient TINYINT(1) NOT NULL DEFAULT 1,
  sort_order INT NOT NULL DEFAULT 0,
  PRIMARY KEY (id),
  UNIQUE KEY uq_product_ingredient_form (product_id, ingredient_id, ingredient_form_id),
  KEY idx_product_ingredients_ingredient (ingredient_id),
  CONSTRAINT fk_product_ingredients_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_product_ingredients_ingredient FOREIGN KEY (ingredient_id) REFERENCES ingredients(id) ON DELETE RESTRICT,
  CONSTRAINT fk_product_ingredients_form FOREIGN KEY (ingredient_form_id) REFERENCES ingredient_forms(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_goal_map (
  product_id BIGINT UNSIGNED NOT NULL,
  goal_id BIGINT UNSIGNED NOT NULL,
  relevance_score DECIMAL(5,2) NULL,
  mapping_source VARCHAR(32) NOT NULL DEFAULT 'derived',
  PRIMARY KEY (product_id, goal_id),
  KEY idx_product_goal_goal (goal_id),
  CONSTRAINT fk_product_goal_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_product_goal_goal FOREIGN KEY (goal_id) REFERENCES wellness_goals(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_concern_map (
  product_id BIGINT UNSIGNED NOT NULL,
  concern_id BIGINT UNSIGNED NOT NULL,
  relevance_score DECIMAL(5,2) NULL,
  mapping_source VARCHAR(32) NOT NULL DEFAULT 'derived',
  PRIMARY KEY (product_id, concern_id),
  KEY idx_product_concern_concern (concern_id),
  CONSTRAINT fk_product_concern_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_product_concern_concern FOREIGN KEY (concern_id) REFERENCES wellness_concerns(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS product_images (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  product_id BIGINT UNSIGNED NOT NULL,
  image_type VARCHAR(32) NOT NULL DEFAULT 'front',
  image_url VARCHAR(1500) NOT NULL,
  source VARCHAR(64) NULL,
  sort_order INT NOT NULL DEFAULT 0,
  is_primary TINYINT(1) NOT NULL DEFAULT 0,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_product_images_product (product_id, is_primary, sort_order),
  CONSTRAINT fk_product_images_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS retailers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(80) NOT NULL,
  name VARCHAR(120) NOT NULL,
  website_url VARCHAR(1000) NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  PRIMARY KEY (id),
  UNIQUE KEY uq_retailers_slug (slug)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS retailer_listings (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  retailer_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  retailer_sku VARCHAR(120) NULL,
  listing_name VARCHAR(500) NULL,
  package_size_label VARCHAR(180) NULL,
  listing_url VARCHAR(1500) NOT NULL,
  image_url VARCHAR(1500) NULL,
  current_price_cents INT UNSIGNED NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  availability VARCHAR(32) NOT NULL DEFAULT 'unknown',
  last_checked_at DATETIME NULL,
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_retailer_listing_sku (retailer_id, retailer_sku),
  KEY idx_retailer_listings_product (product_id, retailer_id),
  KEY idx_retailer_listings_availability (retailer_id, availability),
  CONSTRAINT fk_retailer_listings_retailer FOREIGN KEY (retailer_id) REFERENCES retailers(id) ON DELETE CASCADE,
  CONSTRAINT fk_retailer_listings_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS retailer_price_history (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  retailer_listing_id BIGINT UNSIGNED NOT NULL,
  price_cents INT UNSIGNED NOT NULL,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  observed_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_price_history_listing_date (retailer_listing_id, observed_at),
  CONSTRAINT fk_price_history_listing FOREIGN KEY (retailer_listing_id) REFERENCES retailer_listings(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_goals (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  goal_id BIGINT UNSIGNED NOT NULL,
  priority SMALLINT NOT NULL DEFAULT 1,
  desired_outcome VARCHAR(500) NULL,
  stage VARCHAR(32) NOT NULL DEFAULT 'setup',
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  started_at DATETIME NULL,
  completed_at DATETIME NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_goals_user_status (user_id, status, priority),
  KEY idx_user_goals_goal (goal_id),
  CONSTRAINT fk_user_goals_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_goals_goal FOREIGN KEY (goal_id) REFERENCES wellness_goals(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_concerns (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_goal_id BIGINT UNSIGNED NOT NULL,
  concern_id BIGINT UNSIGNED NOT NULL,
  priority SMALLINT NOT NULL DEFAULT 1,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_goal_concern (user_goal_id, concern_id),
  KEY idx_user_concerns_concern (concern_id),
  CONSTRAINT fk_user_concerns_user_goal FOREIGN KEY (user_goal_id) REFERENCES user_goals(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_concerns_concern FOREIGN KEY (concern_id) REFERENCES wellness_concerns(id) ON DELETE RESTRICT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_saved_products (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  retailer_listing_id BIGINT UNSIGNED NULL,
  state VARCHAR(32) NOT NULL DEFAULT 'considering',
  saved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_user_saved_product (user_id, product_id),
  KEY idx_user_saved_products_state (user_id, state),
  CONSTRAINT fk_user_saved_products_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_saved_products_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_saved_products_listing FOREIGN KEY (retailer_listing_id) REFERENCES retailer_listings(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_cabinet (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  retailer_listing_id BIGINT UNSIGNED NULL,
  user_goal_id BIGINT UNSIGNED NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  started_at DATE NULL,
  purchased_at DATE NULL,
  purchase_price_cents INT UNSIGNED NULL,
  servings_per_day DECIMAL(8,3) NULL,
  estimated_servings_remaining DECIMAL(10,2) NULL,
  estimated_reorder_date DATE NULL,
  stopped_at DATE NULL,
  stop_reason VARCHAR(80) NULL,
  notes TEXT NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_cabinet_user_status (user_id, status),
  KEY idx_user_cabinet_product (product_id),
  CONSTRAINT fk_user_cabinet_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_cabinet_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE RESTRICT,
  CONSTRAINT fk_user_cabinet_listing FOREIGN KEY (retailer_listing_id) REFERENCES retailer_listings(id) ON DELETE SET NULL,
  CONSTRAINT fk_user_cabinet_goal FOREIGN KEY (user_goal_id) REFERENCES user_goals(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_product_events (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  product_id BIGINT UNSIGNED NOT NULL,
  retailer_listing_id BIGINT UNSIGNED NULL,
  event_type VARCHAR(50) NOT NULL,
  metadata_json JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_user_product_events_user_date (user_id, created_at),
  KEY idx_user_product_events_product_type (product_id, event_type),
  CONSTRAINT fk_user_product_events_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_product_events_product FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_product_events_listing FOREIGN KEY (retailer_listing_id) REFERENCES retailer_listings(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS checkins (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  user_goal_id BIGINT UNSIGNED NULL,
  cabinet_item_id BIGINT UNSIGNED NULL,
  overall_result VARCHAR(32) NOT NULL DEFAULT 'not_sure',
  adherence VARCHAR(32) NULL,
  metrics_json JSON NULL,
  notes TEXT NULL,
  checked_in_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_checkins_user_date (user_id, checked_in_at),
  KEY idx_checkins_goal_date (user_goal_id, checked_in_at),
  CONSTRAINT fk_checkins_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_checkins_goal FOREIGN KEY (user_goal_id) REFERENCES user_goals(id) ON DELETE SET NULL,
  CONSTRAINT fk_checkins_cabinet FOREIGN KEY (cabinet_item_id) REFERENCES user_cabinet(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS plans (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  user_goal_id BIGINT UNSIGNED NULL,
  name VARCHAR(255) NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  starts_on DATE NULL,
  ends_on DATE NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_plans_user_status (user_id, status),
  CONSTRAINT fk_plans_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_plans_goal FOREIGN KEY (user_goal_id) REFERENCES user_goals(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS reminders (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  user_goal_id BIGINT UNSIGNED NULL,
  cabinet_item_id BIGINT UNSIGNED NULL,
  reminder_type VARCHAR(50) NOT NULL,
  title VARCHAR(255) NOT NULL,
  due_at DATETIME NOT NULL,
  recurrence_rule VARCHAR(500) NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_reminders_user_due (user_id, status, due_at),
  CONSTRAINT fk_reminders_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_reminders_goal FOREIGN KEY (user_goal_id) REFERENCES user_goals(id) ON DELETE SET NULL,
  CONSTRAINT fk_reminders_cabinet FOREIGN KEY (cabinet_item_id) REFERENCES user_cabinet(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS learning_content (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  slug VARCHAR(220) NOT NULL,
  title VARCHAR(255) NOT NULL,
  summary TEXT NULL,
  body_html MEDIUMTEXT NULL,
  content_type VARCHAR(32) NOT NULL DEFAULT 'micro_lesson',
  duration_seconds INT UNSIGNED NULL,
  related_entity_type VARCHAR(32) NULL,
  related_entity_id BIGINT UNSIGNED NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'published',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_learning_content_slug (slug),
  KEY idx_learning_content_entity (related_entity_type, related_entity_id)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS learning_progress (
  user_id BIGINT UNSIGNED NOT NULL,
  learning_content_id BIGINT UNSIGNED NOT NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'started',
  progress_percent TINYINT UNSIGNED NOT NULL DEFAULT 0,
  started_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  completed_at DATETIME NULL,
  PRIMARY KEY (user_id, learning_content_id),
  CONSTRAINT fk_learning_progress_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_learning_progress_content FOREIGN KEY (learning_content_id) REFERENCES learning_content(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS providers (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  owner_user_id BIGINT UNSIGNED NULL,
  slug VARCHAR(220) NOT NULL,
  display_name VARCHAR(255) NOT NULL,
  provider_type VARCHAR(100) NULL,
  bio TEXT NULL,
  city VARCHAR(120) NULL,
  region VARCHAR(120) NULL,
  country_code CHAR(2) NULL,
  verification_status VARCHAR(32) NOT NULL DEFAULT 'unverified',
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  UNIQUE KEY uq_providers_slug (slug),
  KEY idx_providers_type_status (provider_type, status),
  CONSTRAINT fk_providers_owner FOREIGN KEY (owner_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS provider_goal_map (
  provider_id BIGINT UNSIGNED NOT NULL,
  goal_id BIGINT UNSIGNED NOT NULL,
  relevance_score DECIMAL(5,2) NULL,
  PRIMARY KEY (provider_id, goal_id),
  CONSTRAINT fk_provider_goal_provider FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE,
  CONSTRAINT fk_provider_goal_goal FOREIGN KEY (goal_id) REFERENCES wellness_goals(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS user_provider_saves (
  user_id BIGINT UNSIGNED NOT NULL,
  provider_id BIGINT UNSIGNED NOT NULL,
  saved_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (user_id, provider_id),
  CONSTRAINT fk_user_provider_saves_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_user_provider_saves_provider FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS partner_introductions (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  provider_id BIGINT UNSIGNED NOT NULL,
  user_goal_id BIGINT UNSIGNED NULL,
  reason_code VARCHAR(80) NULL,
  match_score DECIMAL(5,2) NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'eligible',
  sharing_scope_json JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  responded_at DATETIME NULL,
  PRIMARY KEY (id),
  KEY idx_partner_introductions_user_status (user_id, status),
  CONSTRAINT fk_partner_introductions_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
  CONSTRAINT fk_partner_introductions_provider FOREIGN KEY (provider_id) REFERENCES providers(id) ON DELETE CASCADE,
  CONSTRAINT fk_partner_introductions_goal FOREIGN KEY (user_goal_id) REFERENCES user_goals(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agent_conversations (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  user_id BIGINT UNSIGNED NOT NULL,
  title VARCHAR(255) NULL,
  status VARCHAR(32) NOT NULL DEFAULT 'active',
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_agent_conversations_user (user_id, updated_at),
  CONSTRAINT fk_agent_conversations_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS agent_messages (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  conversation_id BIGINT UNSIGNED NOT NULL,
  role VARCHAR(20) NOT NULL,
  content MEDIUMTEXT NOT NULL,
  context_json JSON NULL,
  model_name VARCHAR(120) NULL,
  input_tokens INT UNSIGNED NULL,
  output_tokens INT UNSIGNED NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_agent_messages_conversation (conversation_id, created_at),
  CONSTRAINT fk_agent_messages_conversation FOREIGN KEY (conversation_id) REFERENCES agent_conversations(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS admin_audit_log (
  id BIGINT UNSIGNED NOT NULL AUTO_INCREMENT,
  actor_user_id BIGINT UNSIGNED NULL,
  action VARCHAR(100) NOT NULL,
  entity_type VARCHAR(80) NULL,
  entity_id BIGINT UNSIGNED NULL,
  metadata_json JSON NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (id),
  KEY idx_admin_audit_actor_date (actor_user_id, created_at),
  KEY idx_admin_audit_entity (entity_type, entity_id),
  CONSTRAINT fk_admin_audit_actor FOREIGN KEY (actor_user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

SET FOREIGN_KEY_CHECKS = 1;
