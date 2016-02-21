//
//  MoviesViewController.swift
//  MovieViewer
//
//  Created by The Boss on 2/7/16.
//  Copyright © 2016 The Boss. All rights reserved.
//

import UIKit
import AFNetworking
import MBProgressHUD
import SystemConfiguration


class MoviesViewController:  UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {

    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewCell: ImageCollectionView!
    var movies: [NSDictionary]?
    var endpoint: String!
    
    
        override func viewDidLoad() {
        super.viewDidLoad()
    
        //customizes navigation bar
        self.navigationItem.title = "Flicks"
            if let navigationBar = navigationController?.navigationBar {
                navigationBar.setBackgroundImage(UIImage(named: "movieIcon"), forBarMetrics: .Default)
                
                navigationBar.tintColor = UIColor.lightGrayColor()
            }
            
        let refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: "refreshControlAction:", forControlEvents: UIControlEvents.ValueChanged)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        //calls the movie api
        networkRequest()
        self.collectionView.alwaysBounceVertical = true
        

    
    }
    
    func networkRequest()
    {
        let apiKey = "a07e22bc18f5cb106bfe4cc1f83ad8ed"
        let url = NSURL(string: "https://api.themoviedb.org/3/movie/\(endpoint)?api_key=\(apiKey)")
        let request = NSURLRequest(
            URL: url!,
            cachePolicy: NSURLRequestCachePolicy.ReloadIgnoringLocalCacheData,
            timeoutInterval: 10)
        
        let session = NSURLSession(
            configuration: NSURLSessionConfiguration.defaultSessionConfiguration(),
            delegate: nil,
            delegateQueue: NSOperationQueue.mainQueue()
        )
        MBProgressHUD.showHUDAddedTo(self.view, animated: true)
        
        let task: NSURLSessionDataTask = session.dataTaskWithRequest(request,
            completionHandler: { (dataOrNil, response, error) in
                MBProgressHUD.hideHUDForView(self.view, animated: true)
                if let data = dataOrNil {
                    if let responseDictionary = try! NSJSONSerialization.JSONObjectWithData(
                        data, options:[]) as? NSDictionary {
                            self.movies = responseDictionary["results"] as! [NSDictionary]
                            self.collectionView.reloadData()
                            
                    }
                }
                print("HELLO")
        })
        task.resume()

    }
    
    func refreshControlAction(refreshControl: UIRefreshControl)
    {
        print("I netwokred")
        networkRequest()
        print("REFRESHED")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            if let movies = movies {
                return movies.count
            }
            else {
            return 0
        }
    }
    
    
        func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
            
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier("mainstory", forIndexPath: indexPath) as! ImageCollectionView  
            
            let movie = movies![indexPath.row]
            let baseUrl = "http://image.tmdb.org/t/p/w500/"
            if let posterPath = movie["poster_path"] as? String
            {
                let imageUrl = NSURL(string: baseUrl + posterPath)
                cell.posterView.setImageWithURL(imageUrl!)
            }
            return cell
            
        }
    
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let cell = sender as! UICollectionViewCell
        let indexPath = collectionView.indexPathForCell(cell)
        let movie = movies![indexPath!.row]
        
        let detailViewController = segue.destinationViewController as! DetailViewController
        detailViewController.movie = movie
        
        print("prepare for segue");
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
