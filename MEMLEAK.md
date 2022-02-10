https://www.spacevatican.org/2019/5/4/debugging-a-memory-leak-in-a-rails-app/

"So if anyone's googling this, Class.new creates memory leaks."

http://stratus3d.com/blog/2020/08/11/effective-debugging-of-memory-leaks-in-ruby/
https://stackoverflow.com/questions/43544804/memory-exceeds-in-rails-app-in-production-deployed-on-heroku
https://stackoverflow.com/questions/29384403/profile-memory-between-requests-in-rails-to-find-leaks
https://schneems.com/2017/06/22/a-tale-of-slow-pagination/
https://www.speedshop.co/2015/08/05/rack-mini-profiler-the-secret-weapon.html

--------------------
There is an issue in a commit between the 30 JAN and the 3rd of February 2022

------------

AppSignal

How to Find a Memory Leak
Ruby
The list of steps below assumes you have determined there is a memory leak in your Ruby application but don’t know what is causing it. Your first instinct might be to reach for some memory profiling tool and begin looking at memory allocation over time. Some of these steps might seem like a waste of time, but in practice are the most effective. These first two steps focus on gems. Often times third-party code is more widely used and pitfalls and memory leaks are more widely known.

Check for any unused gems in the Gemfile and remove them
There are numerous tools out there to help you find memory leaks in Ruby applications, but with a large codebase even the best tools still produce a lot of noise. If you find even one unused gem it will greatly reduce the amount of code you need to analyze to find the memory leak. Seldom have I not found at least one or two unused gems when reviewing the Gemfile of a legacy Ruby application. Removing unused gems sometimes has the added benefit of reducing overall memory usage.

Check the issue tracker of each gem still present in the Gemfile for reports of memory leaks
A gem may contain memory leaks that have already been reported on the gem’s issue tracker or mailing list. If you find a ticket or thread that describes something similar to the leak you are experiencing, you may have found your memory leak. If a newer version of the gem contains a fix for the memory leak upgrade to the latest version. If you found a ticket but a fix is not available, you may have to work with the maintainers of the gem to get it fixed or fork the project and fix it yourself. If you don’t find someone on the issue tracker describing your issue the changelogs will show if any released versions of the gem contain fixes for memory leaks. Even if a leak does not seem like the one you are experiencing its best upgrade to a version that doesn’t have any known leaks. If you do not find the source of the leak continue to step 3.

Run Rubocop with the rubocop-performance extension
This isn’t likely to find the cause of the memory leak, but it will alert you to general performance issues, which may give you clues as to where the leak is. If there are any Rubocop performance warnings correct the code and see if the memory leak is still present. The memory leak will likely still be present. If it is continuing to step 4.

Visually review the Ruby code for possible memory leaks
Read through the application code and look for class attributes that grow in size, arrays that grow but never shrink, and long-lived objects. Creating a memory leak is pretty easy. Fix any obvious issues, but don’t spend a ton of time on this; just read through the code quickly and look for any obvious issues. On applications with very large codebases, you may need to skip this step as it will be too time-consuming. If you haven’t found the cause of the leak continue to step 5.

If you still haven’t found the issue, use Ruby’s ObjectSpaceclass to find the leak
Follow the steps in the sections below to profile memory usage.

By using ObjectSpace.each_object.

Ruby already comes with ObjectSpace which contains a few methods for analyzing your program. The most useful for finding memory leaks is ObjectSpace.each_ object which yields every single ruby object in your program.

counts = Hash.new{ 0 }
ObjectSpace.each_object do |o|
counts[o.class] += 1
end
By dumping the counts into a file after each request and using diff it’s possible to determine what kind of objects are leaking. This is essential to know, but it doesn’t give you any insight into why they’re not being garbage collected.