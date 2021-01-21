# frozen_string_literal: true
# This migration comes from decidim_comments (originally 20200706123136)

class MakeCommentsHandleI18n < ActiveRecord::Migration[5.2]
  class User < ApplicationRecord
    self.table_name = :decidim_users
  end

  class Comment < ApplicationRecord
    self.table_name = :decidim_comments_comments
  end

  class Organization < ApplicationRecord
    self.table_name = :decidim_organizations
  end

  def change
    add_column :decidim_comments_comments, :new_body, :jsonb

    User.reset_column_information
    Comment.reset_column_information
    Organization.reset_column_information
    Comment.find_each do |comment|
      locale, org_id = User.where(id: comment.decidim_author_id).where.not(decidim_organization_id: [nil, false]).pluck(:locale, :decidim_organization_id).first
      if org_id.nil?
        comment.destroy!
      else
        locale = locale.presence || Organization.find(org_id).default_locale

        comment.new_body = {
          locale => comment.body
        }

        comment.save!
      end
    end

    remove_column :decidim_comments_comments, :body
    rename_column :decidim_comments_comments, :new_body, :body

    User.reset_column_information
    Comment.reset_column_information
    Organization.reset_column_information
  end
end
