desc "Add discussions to old tasks"
task :add_discussions => :environment do
  Task.all.each do |t|
   p t.create_discussion!(:title => "some sort of discussion")
  end
end
