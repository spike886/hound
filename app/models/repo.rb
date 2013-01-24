class Repo < ActiveRecord::Base
  attr_accessor :name

  attr_accessible :name, :github_id, :active

  validates :github_id, uniqueness: true, presence: true

  scope :active, where(active: true)

  def self.all_by_user(user)
    api = GithubApi.new(user.github_token)
    all_repos = api.get_repos

    active_repo_github_ids = user.repos.active.pluck(:github_id)

    all_repos.map do |repo|
      Repo.new(
        github_id: repo.id,
        name: repo.name,
        active: active_repo_github_ids.include?(repo.id)
      )
    end
  end

  def self.find_by_github_id_and_user(github_id, user)
    where(user_id: user, github_id: github_id).first ||
      NullRepo.new(user: user, github_id: github_id)
  end

  def activate
    update_attribute(:active, true)
  end

  def deactivate
    update_attribute(:active, false)
  end
end