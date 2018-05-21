require 'will_paginate/array'

module Projects
  module Environments
    class GitController < Environments::ApplicationController

      # GET /projects/:project_id/environments/:environment_id/git/clone
      def clone
        begin
          @environment.update_attribute(:clone_status, Environment.clone_statuses[:processing])
          GitCloneJob.perform_later(@environment)
          puts @environment.inspect
          json_success(@environment)
        rescue Exception => e
          logger.error(e)
          logger.error(e.backtrace.join("\n"))
          json_error(e.message)
        end
      end

      # GET /projects/:project_id/environments/:environment_id/git/branches
      def branches
        begin
          unless @environment.git_dir.present?
            json_success
            return
          end
          git = Git.open(@environment.git_dir)
          git.fetch(remote='origin', {prune: true})
          @branches = []
          git.branches.remote.each do |branch|
            @branches << {
                name: branch.name,
                full: branch.full,
                current: @environment.git_branch == branch.name
            }
          end
          branches = @branches.paginate(page: params[:page] || 1)
          json_success(branches)
        rescue => e
          logger_exception(e)
          json_error(e.message)
        end
      end

      # GET /projects/:project_id/environments/:environment_id/git/tags
      def tags
        begin
          git = Git.open(@environment.git_dir)
          git.fetch(remote='origin', {prune: true})
          tags = git.tags.map {|tag| {name: tag.name, current: @environment.git_tag == tag.name}}.reverse.paginate(page: params[:page] || 1)
          json_success(tags)
        rescue => e
          json_error(e.message)
        end
      end

      # PUT /projects/:project_id/environments/:id/git/choose_branch
      def choose_branch
        begin
          branch = params[:branch]
          full = params[:full]
          git = Git.open(@environment.git_dir)
          git.reset_hard
          if git.is_local_branch?(branch)
            git.checkout(branch)
          else
            git.checkout(full, {t: true})
          end
          @environment.git_branch = branch
          @environment.git_tag = ''
          @environment.save
          json_success
        rescue => e
          raise
          json_error(e.message)
        end
      end

      # PUT /projects/:project_id/environments/:id/git/choose_tag
      def choose_tag
        begin
          tag = params[:tag]
          Git.open(@environment.git_dir).checkout(tag)
          @environment.git_tag = tag
          @environment.git_branch = ''
          @environment.save
          json_success
        rescue => e
          raise
          json_error(e.message)
        end
      end

    end
  end
end
