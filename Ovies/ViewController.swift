//
//  ViewController.swift
//  Ovies
//
//  Created by Ben on 25/02/2019.
//  Copyright © 2019 BehorDev. All rights reserved.

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDataSource , UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    final let url = URL(string: "http://api.androidhive.info/json/movies.json")
    private var movies = [Movie]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createOrRetriveData()
    }
    
    
    @IBAction func downloadJsonButton(_ sender: UIButton) {
        downloadJson()
    }
    
    // Downloading the json file and converting it to a Movie Type Object. Ordering the Movies by Release date and loading tabeview before saving in coreData to save time.
    func downloadJson(){
        guard let downloadURL = url else { return }
        URLSession.shared.dataTask(with: downloadURL) { (data, urlResponse, error) in
            guard let data = data, error == nil, urlResponse != nil else{
                print("somthing is wrong")
                return
            }
            do
            {
                let decoder = JSONDecoder()
                let downloadedMovies = try decoder.decode([Movie].self, from: data)
                self.movies = downloadedMovies
                DispatchQueue.main.async {
                    self.movies.sort(by: { $0.releaseYear > $1.releaseYear })
                    self.tableView.reloadData()
                }
            } catch{
                print("something wrong after downloading")
            }
            }.resume()
        
        //i experienced an issue. it takes sometime to download the Json, using a asyncTask with a delay of 2 seconds should give the task enough time to complete downloading the Json, only then we will save the Json in our CoreData.
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.createOrRetriveData()
        }
    }
    
    //create and save data in coreData for the first time.
    //loading exsisting data to the tableView
    //updating the exsisting data to a new data, then reloading Tableview
    func createOrRetriveData(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let userEntity = NSEntityDescription.entity(forEntityName: "Movies", in: managedContext)!
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Movies")
        
        do{
            if try managedContext.count(for: fetchRequest) > 0{
                do
                {
                    let test = try managedContext.fetch(fetchRequest)
                    // this case will happen if we already have data in CoreData, we reloaded the app. creating a Movie Object and loading table view from coreData.
                    if movies.count == 0 {
                        for i in 0...14 {
                            let aMovie = test[i] as! Movies
                            let newMovie = Movie(title: aMovie.title!, image: aMovie.image!, rating: aMovie.rating, releaseYear: Int(aMovie.releaseYear), genre: [aMovie.genre!])
                            movies.append(newMovie)
                        }
                    }
                    for movie in movies{
                        let objectUpdate = test[0] as! NSManagedObject
                        objectUpdate.setValue("\(movie.title)", forKey: "title")
                        objectUpdate.setValue("\(movie.image)", forKey: "image")
                        objectUpdate.setValue(movie.rating, forKey: "rating")
                        objectUpdate.setValue(movie.releaseYear, forKey: "releaseYear")
                        objectUpdate.setValue("\(movie.genre)", forKey: "genre")
                    }
                    do{
                        try managedContext.save()
                    }
                    catch
                    {
                        print(error)
                    }
                    self.movies.sort(by: { $0.releaseYear > $1.releaseYear })
                     tableView.reloadData()
                }
                catch {
                    print(error)
                }
            } else {
                //saving data in coreData for the first time.
                for movie in movies {
                    let user = NSManagedObject(entity: userEntity, insertInto: managedContext)
                    user.setValue("\(movie.title)", forKey: "title")
                    user.setValue("\(movie.image)", forKey: "image")
                    user.setValue(movie.rating, forKey: "rating")
                    user.setValue(movie.releaseYear, forKey: "releaseYear")
                    user.setValue("\(movie.genre.joined(separator: ", "))", forKey: "genre")
                }
                do {
                    try managedContext.save()
                } catch let error as NSError { print("could not save. \(error), \(error.userInfo)")}
            }
        } catch { print(error)}
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movies.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MovieCell") as! MovieCell
        cell.movieLabel.text = "Release Year: \(movies[indexPath.row].releaseYear)"
        
        if
            let imageURL = URL(string: movies[indexPath.row].image){
            DispatchQueue.global().async {
                let data = try? Data(contentsOf: imageURL)
                if let data = data{
                    let image = UIImage(data: data)
                    DispatchQueue.main.async {
                        cell.imageView?.image = image
                    }
                } 
            }
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sbMovieDetailsID") as! MovieDetailsViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
        popOverVC.movieGenre.text = "Genre: \(movies[indexPath.row].genre.joined(separator: ", "))"
        popOverVC.movieTitle.text = "Title: \(movies[indexPath.row].title)"
        popOverVC.movieRating.text = "Rating: \(movies[indexPath.row].rating)"
    }
}

