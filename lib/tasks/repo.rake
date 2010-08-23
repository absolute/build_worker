
namespace "repo" do
  task "checkout" do                                       
    Rake::Task["#{ENV['PROJECT_SCM']}:checkout"].invoke
  end
  task "update" do
    Rake::Task["#{ENV['PROJECT_SCM']}:update"].invoke
  end
end
