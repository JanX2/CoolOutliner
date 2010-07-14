CoolOutliner – NSTreeController Sample Code
===========================================

This repository contains CoolOutliner, a sample application using NSTreeController. It contains the source code and an Xcode project. Most of the initial code came from [Keith Blount’s  “NSTreeControllerTutorial”][1] which is available from his [Literature and Latte - Free Stuff][2] page. I (Jan Weiß) updated it for 10.5 and rewrote parts in ObjC 2.0 where it seemed appropriate to me.  

As I currently don’t have the time to do such an excellent piece of work as Keith’s tutorial, please use his tutorial as a guide to creating an app using an NSOutlineView with an NSTreeController. If you get stuck anywhere, you can compare your version with the one supplied here to help you figure out what may be going wrong. 

You should be able to follow the tutorial up to the point where the drag’n’drop code is added towards the end of the tutorial (see below). The main change I made initially was using 10.5’s NSTreeNode public method -representedObject instead of 10.4’s _NSArrayControllerTreeNode private method -observedObject. 

Drag’n’Drop
-----------

I could not get the original drag’n’drop code to work correctly on 10.5. It changed the underlying array instead of using NSTreeController to apply the changes. Even though his code tells the NSOutlineView to update, it doesn’t refresh. When saving the file and reopening it the changes become visible on 10.5, though. 

Judging from the tutorial and comments, this approach was by design and may have worked or even been necessary on 10.4. On 10.5 however, another approach is required. That is where I used the drag’n’drop code from [Jonathan Dann’s “NSTreeController and Core Data, Sorted.”][4] and merged in some of the extras that Keith had implemented. 

Bits and Pieces
---------------

Additional code is based on and [Jason Swain’s “Saving the expand state of a NSOutlineView”][3]. 

If you have a better idea for solving any of the issues that I have mentioned here or in the commit history or in case you find any bugs, please fork this on github, apply your changes and send a pull request to me. 

License
-------

Copyright (c) 2010, Jan Weiß (github@geheimwerk.de)  
All rights reserved. 

Contains “Sorted Tree” by Jonathan Dann

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

- Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

- Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

- Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS “AS IS” AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

  [1]: http://www.literatureandlatte.com/freestuff/NSTreeControllerTutorial.zip
  [2]: http://www.literatureandlatte.com/freestuff/index.html
  [3]: http://gibbston.net/?p=4
  [4]: http://espresso-served-here.com/2008/05/13/nstreecontroller-and-core-data-sorted/
