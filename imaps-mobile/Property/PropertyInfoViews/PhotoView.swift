import SwiftUI
struct PhotoView: View {
    let photos: [[String : Any]]
    var body: some View {
        VStack {
            ForEach(0..<photos.count, id:\.self) { i in
                let photo: [String : Any] = photos[i]
                VStack {
                    if (photo["IMAGEDIR"] != nil) {
                        let url = "https://services.wake.gov/realestate/photos/mvideo/\(unwrap(any:photo["IMAGEDIR"]) )/\(unwrap(any:photo["IMAGENAME"]) )"
                        AsyncImage(url: URL(string:url),
                                   content: { image in
                            image.resizable()
                                .aspectRatio(contentMode: .fit)
                        }, placeholder: {
                            ProgressView()
                        })
                        
                    }
                    
                    
                }
            }
        }
        
    }
}

struct PhotoViews_Previews: PreviewProvider {
    static var previews: some View {
        
        PhotoView(photos: [["PRIMARYIMAGE": 0, "RESHOOT": 0, "SKETCH": 0, "SURFACE": 1, "UC": 0, "IMAGEDIR": "20080207", "STATUS": "A", "VACANT": 0, "OBJECTID": 672161, "DETAIL": 0, "QUESTIONABLE": 0, "DATECREATED": "2008-02-07 05:00:00 +0000", "NA": 0, "PARCEL": "0350475", "MOBILEHOME": 0, "HISTORY": 1, "CARD": 0, "NOTES": "644 PIPER STREAM CIR", "DOCUMENT": 0, "IMAGENAME": "A7101358.jpg"], ["SKETCH": 0, "DETAIL": 0, "PARCEL": "0350475", "OBJECTID": 672162, "QUESTIONABLE": 0, "MOBILEHOME": 0, "DOCUMENT": 0, "RESHOOT": 0, "UC": 0, "DATECREATED": "2021-04-29 04:00:00 +0000", "HISTORY": 0, "STATUS": "A", "VACANT": 0, "NOTES": "644 PIPER STREAM CIR", "IMAGENAME": "ILA0350475.jpg", "NA": 0, "SURFACE": 1, "CARD": 0, "IMAGEDIR": "20210429", "PRIMARYIMAGE": 1]])
    }
}
