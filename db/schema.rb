# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20190118003117) do

  create_table "build_histories", force: :cascade do |t|
    t.integer  "scenario_id",         limit: 4,                  null: false
    t.integer  "build_no",            limit: 4,                  null: false
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string   "device",              limit: 255, default: "ie", null: false
    t.integer  "branch_no",           limit: 4,   default: 1,    null: false
    t.integer  "result",              limit: 4,   default: 0,    null: false
    t.string   "build_sequence_code", limit: 255
  end

  add_index "build_histories", ["scenario_id", "branch_no"], name: "index_build_histories_on_scenario_id_and_branch_no", using: :btree

  create_table "projects", force: :cascade do |t|
    t.string   "name",                        limit: 255,                 null: false
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
    t.boolean  "deleted",                                 default: false, null: false
    t.integer  "lock_version",                limit: 4,   default: 0,     null: false
    t.string   "redmine_host",                limit: 255
    t.string   "redmine_api_key",             limit: 255
    t.string   "redmine_identifier",          limit: 255
    t.boolean  "use_redmine",                             default: false, null: false
    t.string   "default_build_sequence_code", limit: 255
  end

  create_table "scenarios", force: :cascade do |t|
    t.integer  "project_id",        limit: 4,                   null: false
    t.string   "file",              limit: 255,                 null: false
    t.string   "content_type",      limit: 255,                 null: false
    t.string   "original_filename", limit: 255,                 null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "deleted",                       default: false, null: false
    t.string   "name",              limit: 255,                 null: false
    t.integer  "scenario_no",       limit: 4
  end

  add_index "scenarios", ["project_id"], name: "index_scenarios_on_project_id", using: :btree

  create_table "steps", force: :cascade do |t|
    t.integer  "steppable_id",    limit: 4,                     null: false
    t.integer  "step_no",         limit: 4
    t.string   "command",         limit: 255,   default: "",    null: false
    t.text     "target",          limit: 65535,                 null: false
    t.text     "value",           limit: 65535,                 null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.boolean  "deleted",                       default: false, null: false
    t.string   "steppable_type",  limit: 255,                   null: false
    t.string   "encrypted_value", limit: 255
    t.float    "processing_time", limit: 24
    t.text     "raw_targets",     limit: 65535,                 null: false
    t.text     "comment",         limit: 65535,                 null: false
  end

  add_index "steps", ["steppable_type", "steppable_id"], name: "index_steps_on_steppable_type_and_steppable_id", using: :btree

  create_table "system_settings", force: :cascade do |t|
    t.string   "selenium_host", limit: 255, null: false
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

end
