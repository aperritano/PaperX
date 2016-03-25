//
//  CardUIViewController.swift
//  Koloda
//
//  Created by Eugene Andreyev on 7/11/15.
//  Copyright (c) 2015 CocoaPods. All rights reserved.
//

import UIKit
import Koloda
import pop

private let numberOfCards: UInt = 5
private let frameAnimationSpringBounciness:CGFloat = 9
private let frameAnimationSpringSpeed:CGFloat = 16
private let kolodaCountOfVisibleCards = 2
private let kolodaAlphaValueSemiTransparent:CGFloat = 0.1

class CardUIViewController: UIViewController {
    
    var selectedSession: Session!
    var papers : [PaperEntry]!
    var currentPaperStack : [String] = []
    var currentCard: CardUIView?
    var paperIndex = 0

    @IBOutlet weak var kolodaView: CustomKolodaView!
    
    var dataController: DataController?
    required internal init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
  
    func configure() {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
        dataController = appDelegate.dataController
    }
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        kolodaView.alphaValueSemiTransparent = kolodaAlphaValueSemiTransparent
        kolodaView.countOfVisibleCards = kolodaCountOfVisibleCards
        kolodaView.delegate = self
        kolodaView.dataSource = self
        self.modalTransitionStyle = UIModalTransitionStyle.FlipHorizontal

        if let title = selectedSession.title {
            self.updateTitle(title)
            //let p = selectedSession.papers!.allObjects as! [PaperEntry]
            //self.papers = p.filter( {$0.isLiked == nil })
        } else {
            self.title = ""
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let title = selectedSession.title {
            self.updateTitle(title)
        }
    }

    //MARK: IBActions
    @IBAction func leftButtonTapped(sender: UIButton){
        kolodaView?.swipe(SwipeResultDirection.Left)
    }
    
    @IBAction func rightButtonTapped(sender: UIButton) {
        kolodaView?.swipe(SwipeResultDirection.Right)
    }

    
    @IBAction func undoButtonTapped() {
        kolodaView?.revertAction()
    }
    
    func updateEntities() {
        self.selectedSession = dataController?.fetchSession(selectedSession.uuid!)
        let p = selectedSession.papers!.allObjects as! [PaperEntry]
        let paperNotLiked = p.filter( {$0.isLiked == nil })
        self.papers = paperNotLiked
    }

    func updateTitle(title: String) {
        if let totalPaperCount = self.selectedSession.papers?.count {
            if let liked = self.selectedSession.papers?.filter( {$0.isLiked == true }).count {
                self.title = "\(title) \(liked) of \(totalPaperCount)"
            }
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        self.updateEntities()
//        currentPaperStack = []
    }

}

//MARK: KolodaViewDelegate
extension CardUIViewController: KolodaViewDelegate {
    func koloda(kolodaDidRunOutOfCards koloda: KolodaView) {
        //Example: reloading
        //kolodaView.resetCurrentCardNumber()
    }
    
    
    func koloda(koloda: KolodaView, didSwipedCardAtIndex index: UInt, inDirection direction: SwipeResultDirection) {
        
        let paperUUID = currentPaperStack[Int(index)]
        let found = self.papers.filter({$0.uuid == paperUUID })[0]

        //print("SWIPED card \(currentPaper.title) paperIndex \(paperIndex) index \(index)")


        switch direction {
        case .Left :
            //print("SWIPE NOT \(paperIndex)")
            
            found.isLiked = false
            dataController?.updatePaperEntry(found)
            updateEntities()
            paperIndex += 1
        case .Right :
            found.isLiked = true
            dataController?.updatePaperEntry(found)
            updateEntities()
            paperIndex += 1
        default:
            print("NONE")
        }

        if let title = selectedSession.title {
            self.updateTitle(title)
        }
    }
//    func koloda(koloda: KolodaView, didSelectCardAtIndex index: UInt) {
//        UIApplication.sharedApplication().openURL(NSURL(string: "http://yalantis.com/")!)
//    }
    
    func koloda(kolodaShouldApplyAppearAnimation koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaShouldMoveBackgroundCard koloda: KolodaView) -> Bool {
        return true
    }
//
    func koloda(kolodaShouldTransparentizeNextCard koloda: KolodaView) -> Bool {
        return true
    }
    
    func koloda(kolodaBackgroundCardAnimation koloda: KolodaView) -> POPPropertyAnimation? {
        let animation = POPSpringAnimation(propertyNamed: kPOPViewFrame)
        animation.springBounciness = frameAnimationSpringBounciness
        animation.springSpeed = frameAnimationSpringSpeed
        return animation
    }
}

//MARK: KolodaViewDataSource
extension CardUIViewController: KolodaViewDataSource {



    func koloda(kolodaNumberOfCards koloda:KolodaView) -> UInt {
        return UInt(papers.count)
    }
    
    func koloda(koloda: KolodaView, viewForCardAtIndex index: UInt) -> UIView {

        let localIndex = Int(index)
        let adjustedIndex = paperIndex + localIndex
        
//        print("card index \(localIndex)  - paper index \(paperIndex) - adjusted index \(adjustedIndex)")
//
        let card = (NSBundle.mainBundle().loadNibNamed("CardUIView",
            owner: self, options: nil)[0] as? CardUIView)!
        
        if adjustedIndex < papers.count {
            let paperEntry = papers![adjustedIndex]

            print("paper uuid \(paperEntry.uuid)")

            currentPaperStack.append(paperEntry.uuid!)
            //print("\(paperEntry.title)")
            card.populateCard(paperEntry)
            print("ADDED \(paperEntry.title!) - local - \(localIndex) - papIndex - \(paperIndex)")
            print("stack: \(currentPaperStack.count)")
        }
        return card
    }
    
    func koloda(koloda: KolodaView, viewForCardOverlayAtIndex index: UInt) -> OverlayView? {
        return NSBundle.mainBundle().loadNibNamed("CustomOverlayView",
            owner: self, options: nil)[0] as? OverlayView
    }
}
