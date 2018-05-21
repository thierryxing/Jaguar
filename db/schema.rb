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

ActiveRecord::Schema.define(version: 20180411100334) do

  create_table "builds", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "version"
    t.integer "status"
    t.integer "project_id"
    t.string "build_number"
    t.string "job_id"
    t.string "release_notes"
    t.boolean "snapshot"
    t.integer "user_id"
    t.integer "env_template"
    t.integer "environment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "dependencies", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "version"
    t.integer "project_id"
    t.boolean "is_internal", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "environments", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "git_branch"
    t.string "scheme"
    t.integer "project_id"
    t.integer "build_template"
    t.boolean "is_default"
    t.string "main_module"
    t.string "gradle_task"
    t.string "name"
    t.integer "clone_status", default: 0
    t.string "ding_access_token"
    t.string "cron"
    t.integer "fastlane_template_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "git_tag"
  end

  create_table "fastlane_templates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "command"
    t.string "platform"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "title"
    t.string "desc"
    t.string "icon"
    t.string "git_repo_url"
    t.integer "git_project_id"
    t.string "type", default: "0"
    t.integer "platform", default: 0
    t.integer "admin_id"
    t.integer "user_id"
    t.string "identifier"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "release_notes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "content"
    t.string "author"
    t.integer "build_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "services", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "type"
    t.string "title"
    t.integer "environment_id"
    t.boolean "active", default: false, null: false
    t.text "properties"
    t.boolean "template", default: false
    t.integer "service_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "apple_id"
    t.string "apple_id_password"
    t.string "apple_team_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "name"
    t.string "username"
    t.string "gitlab_id"
    t.string "state"
    t.string "avatar_url"
    t.boolean "is_admin"
    t.string "private_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
