//
//  FeedViewController.swift
//  instagramClone
//
//  Created by Richard Basdeo on 3/9/21.
//

import UIKit
import Parse
import Alamofire
import MessageInputBar

class FeedViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    let myRefreshControl = UIRefreshControl()
    
    let commentBar = MessageInputBar()
    
    var showMessageBar = false
    
    var selectedPost: PFObject!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        commentBar.inputTextView.placeholder = "Add a comment..."
        commentBar.sendButton.title = "Post"
        commentBar.delegate = self
        
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
        
        tableView.keyboardDismissMode = .interactive
        
        let center = NotificationCenter.default
        center.addObserver(self,
                           selector: #selector(keyboardWillBeHiddent(note:)),
                           name: UIResponder.keyboardWillHideNotification,
                           object: nil)
    }
    
    @objc func keyboardWillBeHiddent(note: Notification){
        commentBar.inputTextView.text = nil
        showMessageBar = false
        becomeFirstResponder()
    }
    
    override var inputAccessoryView: UIView? {
        return commentBar
    }
    
    override var canBecomeFirstResponder: Bool {
        
        return showMessageBar
        
    }
    
    
    
    
    @objc func loadPosts () {
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
            self.myRefreshControl.endRefreshing()
        }
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let query = PFQuery(className: "Posts")
        query.includeKeys(["author", "comments", "comments.author"])
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func logOutPressed(_ sender: UIBarButtonItem) {
        
        PFUser.logOut()
        
        let main = UIStoryboard(name: "Main", bundle: nil)
        let loginViewController = main.instantiateViewController(identifier: "loginViewController")
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let delegate = windowScene.delegate as? SceneDelegate else {return}
        delegate.window?.rootViewController = loginViewController
        
        
    }
    
    
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let post = posts[section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        return comments.count + 2
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.section]
        let comments = (post["comments"] as? [PFObject]) ?? []
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as! PostCell
            
            let user = post["author"] as! PFUser
            cell.userNameLabel.text = user.username
            cell.captionNameLabel.text = post["caption"] as! String
            
            let imageFile = post["image"] as! PFFileObject
            let urlString = imageFile.url!
            let url = URL(string: urlString)
            
            cell.photoView.af.setImage(withURL: url!)
            
            return cell
        }
        else if indexPath.row <= comments.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "CommentTableViewCell") as! CommentTableViewCell
            let comment = comments[indexPath.row - 1]
            cell.authorComment.text = comment["text"] as? String
            let user = comment["author"] as! PFUser
            cell.authorPost.text = user.username
            
            return cell
        }
        
        else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "AddCommentCell")!
            return cell
            
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = UIColor.red
        spinner.hidesWhenStopped = true
        tableView.tableFooterView = spinner
        
        //print (indexPath.row)
        if (indexPath.row  == posts.count - 1) {
            
            spinner.startAnimating()
            loadPosts()
            spinner.stopAnimating()
        }
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let post = posts[indexPath.section]
        let comments = post["comments"] as? [PFObject] ?? []
        
        
        
        
        if (indexPath.row == comments.count + 1){
            showMessageBar = true
            becomeFirstResponder()
            commentBar.inputTextView.becomeFirstResponder()
            
            selectedPost = post
        }
        
    }
    
    
    
}

extension FeedViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        //create the comment\
        let comment = PFObject(className: "Comments")
        comment["text"] = text
        comment["post"] = selectedPost
        comment["author"] = PFUser.current()!
        
        selectedPost.add(comment, forKey: "comments")
        
        selectedPost.saveInBackground() {(success, error) in
            
            if (success) {
                print ("Comment saved")
            }
            else {
                print("Error saving comment")
            }
        }
        tableView.reloadData()
        
        
        
        //dismiss
        commentBar.inputTextView.text = nil
        showMessageBar = false
        becomeFirstResponder()
        commentBar.inputTextView.resignFirstResponder()
    }
}
