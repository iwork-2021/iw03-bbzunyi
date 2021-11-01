//
//  ContentViewController.swift
//  ITSC
//
//  Created by bb on 2021/10/28.
//

import UIKit
import SwiftSoup
class ContentViewController: UIViewController {

    @IBOutlet weak var news_title: UILabel!
    @IBOutlet weak var text1: UITextView!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var text2: UITextView!
    var html:String = ""
    
    func loadContent(){
        do {
            let document = try SwiftSoup.parse(self.html)
            let content:Element = try document.select("meta.description").first()!
            let constr:String = try content.attr("content")
            var startIndex = constr.index(constr.startIndex, offsetBy: 0)
            var endIndex =  constr.index(constr.startIndex, offsetBy: 200)
            self.text1.text = String(constr[startIndex..<endIndex])
            startIndex = constr.index(constr.startIndex, offsetBy: 200)
            endIndex =  constr.index(constr.startIndex, offsetBy:constr.count )
            self.text2.text = String(constr[startIndex..<endIndex])
        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
    }
    
    func loadhtml(news_item:NewsItem){
        //self.news_title.text! = news_item.title
        print(self.news_title.text!)
        news_title.text = news_item.title
        let url = URL(string: news_item.website)!
        let task = URLSession.shared.dataTask(with: url, completionHandler: {
            data, response, error in
            if let error = error {
                print("\(error.localizedDescription)")
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode) else {
                print("server error")
                return
            }
            if let mimeType = httpResponse.mimeType, mimeType == "text/html",
                let data = data,
                let string = String(data: data, encoding: .utf8) {
                    DispatchQueue.main.sync {
                        self.html = string
                        self.loadContent()
                    }
                }
        })
        task.resume()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
