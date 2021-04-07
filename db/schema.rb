# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_04_07_123448) do

  create_table "date_of_prices", force: :cascade do |t|
    t.date "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hotel_competitors", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "hotel_id"
    t.index ["hotel_id"], name: "index_hotel_competitors_on_hotel_id"
    t.index ["user_id"], name: "index_hotel_competitors_on_user_id"
  end

  create_table "hotel_owners", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "hotel_id"
    t.index ["hotel_id"], name: "index_hotel_owners_on_hotel_id"
    t.index ["user_id"], name: "index_hotel_owners_on_user_id"
  end

  create_table "hotels", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_reservation_code"
    t.integer "reservation_manager_id"
    t.string "reservation_url"
    t.integer "user_id"
    t.integer "capacity"
    t.index ["reservation_manager_id"], name: "index_hotels_on_reservation_manager_id"
    t.index ["user_id"], name: "index_hotels_on_user_id"
  end

  create_table "ota_coefficients", force: :cascade do |t|
    t.boolean "is_coefficient"
    t.float "coefficient_value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.index ["hotel_id"], name: "index_ota_coefficients_on_hotel_id"
  end

  create_table "ota_prices", force: :cascade do |t|
    t.integer "price"
    t.string "provider"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.integer "date_of_price_id"
    t.integer "scraping_session_id_id"
    t.boolean "available"
    t.index ["date_of_price_id"], name: "index_ota_prices_on_date_of_price_id"
    t.index ["hotel_id"], name: "index_ota_prices_on_hotel_id"
    t.index ["scraping_session_id_id"], name: "index_ota_prices_on_scraping_session_id_id"
  end

  create_table "ota_scrapers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "price_equivalences", force: :cascade do |t|
    t.integer "price_category"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.integer "user_id"
    t.index ["user_id"], name: "index_price_equivalences_on_user_id"
  end

  create_table "prices", force: :cascade do |t|
    t.integer "price"
    t.boolean "available"
    t.integer "n_of_units_available"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.integer "date_of_price_id"
    t.integer "room_category_id"
    t.integer "scraping_session_id"
    t.integer "ota_price"
    t.index ["date_of_price_id"], name: "index_prices_on_date_of_price_id"
    t.index ["hotel_id"], name: "index_prices_on_hotel_id"
    t.index ["room_category_id"], name: "index_prices_on_room_category_id"
    t.index ["scraping_session_id"], name: "index_prices_on_scraping_session_id"
  end

  create_table "reservation_managers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservit_scrapers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "room_categories", force: :cascade do |t|
    t.string "name"
    t.integer "room_code"
    t.integer "number_of_units"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.string "room_type_name"
    t.index ["hotel_id"], name: "index_room_categories_on_hotel_id"
  end

  create_table "room_equivalences", force: :cascade do |t|
    t.boolean "is_percentage"
    t.boolean "is_addition"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.integer "room_category_id"
    t.integer "price_equivalence_id"
    t.index ["hotel_id"], name: "index_room_equivalences_on_hotel_id"
    t.index ["price_equivalence_id"], name: "index_room_equivalences_on_price_equivalence_id"
    t.index ["room_category_id"], name: "index_room_equivalences_on_room_category_id"
  end

  create_table "scraper_availpros", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "scraping_errors", force: :cascade do |t|
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.integer "date_of_price_id"
    t.integer "scraping_session_id"
    t.string "url_date"
    t.text "error"
    t.boolean "price_type_ota"
    t.boolean "price_type_hotel"
    t.text "response"
    t.boolean "available"
    t.index ["date_of_price_id"], name: "index_scraping_errors_on_date_of_price_id"
    t.index ["hotel_id"], name: "index_scraping_errors_on_hotel_id"
    t.index ["scraping_session_id"], name: "index_scraping_errors_on_scraping_session_id"
  end

  create_table "scraping_sessions", force: :cascade do |t|
    t.datetime "date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.boolean "is_ota_type"
    t.index ["hotel_id"], name: "index_scraping_sessions_on_hotel_id"
  end

  create_table "synxis_scrapers", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tripadvisor_requests", force: :cascade do |t|
    t.text "request_body"
    t.string "proxy"
    t.string "hotel_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "hotel_id"
    t.string "date"
    t.index ["hotel_id"], name: "index_tripadvisor_requests_on_hotel_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "password_digest"
    t.string "email"
    t.string "token"
  end

end
