//#-hidden-code
import Foundation
import PlaygroundSupport
import UIKit

PlaygroundPage.current.needsIndefiniteExecution = true
//#-end-hidden-code
/*:
 ### Shadow Play - An Introduction
 This playground is aimed at getting parents and kids together to have fun with Hand Shadow Puppet. Before working on this playground, I spent quite a lot of time to think "What should I create" for the WWDC scholarship. I planned to make something simple (as I have not much time to work on the playground), creative and full of fun. In one night, I was checking email in a dark room. To protect my precious eyes, I turned on my iPhone's flashlight to make the room a little bit brighter. Suddenly, I heard some giggles. My kids were playing with their own shadow! And this inspired me. I can make something to help kids and parents to have fun with hand shadow puppets! Shadow puppetry can help kids to be more imaginative & enhance their storytelling skills. Most importantly, it is really funny!
 
 I chose 4 single-hand shadow puppets as parent or kid can learn while holding an iPad. Different from those difficult puppets, these puppets are very easy to learn. Even a 3-4-year-old kid can learn it. With this playground, I and my sons are getting more close. And I wish the player of this playground can have fun with his/her family too!
 
 ### Step to Learn How to Show a Hand Puppet.
 1. Please run this playground with iPad with Landscape Right orientation
 2. Click "Run My Code" (And allow the camera usage)
 3. Choose the animal you would like to learn 🐕, 🦍, 🐪 or 🐇
 4. Imitate the pose using your right hand
 5. (Depend on hardware avaibility) If torch is supported (you can see a button!), try it in a dark room!
 
 And you can learn making shadow puppet like this:
 
 ![Shadow Puppet Example](camel_4_mth.gif)
 */

//: ### Secret to make thing works!
//Create the learn view controller
var learnViewController = LearnViewController()

//Construct the UI
learnViewController.setupUI()

//And show you the magic!
PlaygroundPage.current.liveView = learnViewController
/*:
 
### Watch my younger son enjoys playing with Hand Shadow Puppet with the prototype I created with iPhone and Xcode!

 ![](arthas.mov poster="arthas.jpg" width="360" height="640")

I also used CreateML to create an AI to check whether you to the correct Shadow Puppet, you may try the *Challege Mode*!

[Practice](@next)
 
*Image credits go to Florida Center for Instructional Technology, College of Education, University of South Florida & Ms. Yuen Yi LAU, one of my good friend & mother of two adorable girls*
*/
