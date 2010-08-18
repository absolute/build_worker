
namespace "repo" do
  task "checkout" do                                       
    Rake::Task["#{ENV['REPO_TYPE']}:checkout"].invoke
  end
  task "update" do
    Rake::Task["#{ENV['REPO_TYPE']}:update"].invoke
  end
end
