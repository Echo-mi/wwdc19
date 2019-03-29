//#-hidden-code
import Foundation
import PlaygroundSupport
//#-end-hidden-code

/*:
 ### Practice Mode
 
 After finished the Learn page, I start to think: Is it possible to use A.I. to check whether I do the hand pose correctly? Thus, I used create ML to create a classifer model and put into CoreML. You may use it to practise your learnt hand poses.
 
 ### Step to create the model
 1. Take a series of photos of hand pose
 2. Classifer the photos into different folders
 3. Make a macOS swift play using xcode with *MLImageClassifierBuilder*
 4. Put the root folder of images and wait for the result!
 
 ### Now, that's your turn to practise the learnt hand poses.
 
 ![Time to practise](fymeme.jpg)
 */

/*:
### Run the code - *play it with a white background*

 Practice with a white wall will give the best result
 
 ![](practice.mov poster="practice.png" width="480" height="320")
 */

//Create the learn view controller
var practiceViewController = PracticeViewController()

//Construct the UI
practiceViewController.setupUI()

//And show you the magic!
PlaygroundPage.current.liveView = practiceViewController

/*:
 ### To make it better
 I think that the samples collected are not quite enough. To make it better, I will collect more samples from friends, classmates, my kids and colleagues. Later on, I may add more hand pose to make it more fun!

 ### Forgot the hand pose?
 [Go back to learn again](@previous)

 *Image credit go to 4chan and those amazing online community*
 */
