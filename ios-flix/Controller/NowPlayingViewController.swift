//
//  NowPlayingViewController.swift
//  ios-flix
//
//  Created by peter on 11/9/18.
//  Copyright © 2018 petecit. All rights reserved.
//

import UIKit
import AlamofireImage
import KRProgressHUD

class NowPlayingViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    // store the movies in a property to use elsewhere
    //var movies: [[String: Any]] = []
    var movies: [Movie] = []
    
    var refreshControl: UIRefreshControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(NowPlayingViewController.didPullToRefresh(_:)), for: .valueChanged)
        
        tableView.insertSubview(refreshControl, at: 0)
        
        tableView.dataSource = self
        tableView.rowHeight = 150

        //fetchMovies()
        MovieApiManager().getNowPlayingMovies { (movies, error) in
            if let movies = movies {
                self.movies = movies
                self.tableView.reloadData()
            }
        }
    }
    
    @objc func didPullToRefresh(_ refreshControl: UIRefreshControl) {
        //fetchMovies()
        MovieApiManager().getNowPlayingMovies { (movies, error) in
            if let movies = movies {
                self.movies = movies
                self.tableView.reloadData()
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    func fetchMovies() {
        showLoadingState()
        let url = URL(string: "https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed")!
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10)
        let session = URLSession(configuration: .default, delegate: nil, delegateQueue: OperationQueue.main)
        let task = session.dataTask(with: request) { (data, response, error) in
            // This will run when the network request returns
            if let error = error {
                print(error.localizedDescription)
            } else if let data = data {
                let dataDictionary = try! JSONSerialization.jsonObject(with: data, options: []) as! [String: Any]
                //print(dataDictionary)
                
                // get the array of movies
                //let movies = dataDictionary["results"] as! [[String: Any]]
                //self.movies = movies
                
                // reload your table view data
                self.tableView.reloadData()
                
                self.refreshControl.endRefreshing()
            }
        }
        task.resume()
    }
    
    func showLoadingState() {
        KRProgressHUD.show()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+3) {
            KRProgressHUD.dismiss()
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Retrieve JSON information
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell", for: indexPath) as! MovieCell
        // Activate property observer in MovieCell class
        cell.movie = movies[indexPath.row]
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let cell = sender as! UITableViewCell
        if let index = tableView.indexPath(for: cell) {
            let detailViewController = segue.destination as! DetailViewController
            detailViewController.movie = movies[index.row]
        }
        
    }
}
