//
//  FeedViewController.swift
//  instagramClone
//
//  Created by Richard Basdeo on 3/9/21.
//

import UIKit
import Parse
import Alamofire

class FeedViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var posts = [PFObject]()
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        
        myRefreshControl.addTarget(self, action: #selector(loadPosts), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    @objc func loadPosts () {
        
        let query = PFQuery(className: "Posts")
        query.includeKey("author")
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
        query.includeKey("author")
        query.limit = 20
        
        query.findObjectsInBackground { (posts, error) in
            
            if posts != nil {
                self.posts = posts!
                self.tableView.reloadData()
            }
        }
    }
}

extension FeedViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let post = posts[indexPath.row]
        
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
}
