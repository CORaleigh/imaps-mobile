//
//  Services.swift
//  imaps-mobile
//
//  Created by Greco, Justin on 5/2/24.
//

import SwiftUI
import ArcGIS
import ArcGISToolkit

struct Services: View, Equatable {
    static func == (lhs: Services, rhs: Services) -> Bool {
        return true
    }
    @ObservedObject var mapViewModel: MapViewModel
    @ObservedObject var propertyInfoViewModel : PropertyInfoViewModel
    @ObservedObject var serviceViewModel: ServiceViewModel
    @State var selectedCategory: Int = 0
    @State var searching: Bool = false

    init(mapViewModel: MapViewModel, propertyInfoViewModel: PropertyInfoViewModel) {
        self.mapViewModel = mapViewModel
        self.serviceViewModel = ServiceViewModel(mapViewModel: mapViewModel)
        self.propertyInfoViewModel = propertyInfoViewModel
    }
    var body: some View {
        VStack  (alignment: .leading){
            HStack (alignment: .center) {
                Text("Category").font(.subheadline)
                    .frame(maxWidth: 100)
                Picker("Category", selection: $selectedCategory) {
                    ForEach(0..<serviceViewModel.categories.count, id:\.self) { i in
                        Text(serviceViewModel.categories[i].title).tag(i)
                    }
                }
                .pickerStyle(.automatic)
                .frame(maxWidth: .infinity)
                .padding(.all)
            }
            .background(Color(UIColor.tertiarySystemBackground))
            .border(Color(UIColor.tertiarySystemBackground), width: 5)
            .cornerRadius(20)
            .padding(.all)
            
        }.frame(maxWidth: .infinity, alignment: .leading)
        ScrollView {

            if (searching) {
                GeometryReader { geometry in
                    VStack {
                        ProgressView().controlSize(.large)
                            .progressViewStyle(CircularProgressViewStyle())
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height*10)
                }
            } else {
                if (serviceViewModel.popupGroups.isEmpty) {
                    HStack {
                        Spacer()
                        
                        Text("No information available")
                        Spacer()
                    }.padding(.all)
                }
                ForEach(serviceViewModel.popupGroups) { group in
                    VStack {
                        Spacer()

                        Text(group.title).font(.title2)
                        ForEach(group.popupElements.indices, id: \.self) { elementIndex in
                            let element = group.popupElements[elementIndex]
                            VStack {
                                if let fieldElement = element as? FieldsPopupElement {
                                    FieldsPopupElementView(fieldElement: fieldElement)
                                } else {
                                    if let mediaElement = element as? MediaPopupElement {
                                        MediaPopupElementView(mediaElement: mediaElement)
                                            
                                    } else {
                                        if let textElement = element as? TextPopupElement {
                                            TextPopupElementView(textElement: textElement)

                                        }
                                    }

                                }
                            }
                        }
                        Divider()
                    }
                }

            }

            
        }.background(Color("Background"))
            .onChange(of: selectedCategory, perform: { index in
                Task {
                    searching = true
                    try await serviceViewModel.getPopups(selectedCategory: serviceViewModel.categories[selectedCategory], property: propertyInfoViewModel.property)
                    searching = false
                }
            })
            .onReceive(propertyInfoViewModel.$property) { feature in
                Task {
                    searching = true
                    try await serviceViewModel.getPopups(selectedCategory: serviceViewModel.categories[selectedCategory], property: feature)
                    searching = false
                }

                
            }.frame(maxWidth: .infinity, alignment: .leading)
    }
}

//#Preview {
//    Services()
//}




struct FieldsPopupElementView: View {
    let fieldElement: FieldsPopupElement

    var body: some View {
        ForEach(fieldElement.labels.indices, id: \.self) { fieldIndex in
            let field = fieldElement.fields[fieldIndex]
            if (field.isVisible) {
                Grid {
                    GridRow {
                        let value = fieldElement.formattedValues[fieldIndex]
                        Text(fieldElement.labels[fieldIndex])
                        if value.starts(with: "http") {
                            if let url = URL(string: value) {
                                Link("View", destination: url)
                            } else {
                                Text("Invalid URL")
                            }
                        } else {
                            Text(value)
                        }
                    }

                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.all)
                }
            }
//            HStack {
//                Text(field.label)
//                Text(fieldElement.formattedValues[fieldIndex])
//            }

        }
    }
}

struct MediaPopupElementView: View {
    let mediaElement: MediaPopupElement

    var body: some View {
        ForEach(mediaElement.media.indices, id: \.self) { mediaIndex in
            let media = mediaElement.media[mediaIndex]
            if media.kind == PopupMedia.Kind.image {
                if let sourceURL = media.value?.sourceURL {
                    AsyncImage(url: sourceURL,
                               content: { image in
                        image.resizable().aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 0.5)
                                }, placeholder: {
                                    ProgressView()
                                    
                                }).padding()
                }
            }
        }

    }
}
struct TextPopupElementView: View {
    /// The `PopupElement` to display.
    var textElement: TextPopupElement
    
    /// The calculated height of the `HTMLTextView`.
    @State private var webViewHeight: CGFloat = .zero
    
    var body: some View {
        if !textElement.text.isEmpty {
            ZStack {
                Color("Background")
                HTMLTextView(html: textElement.text, height: $webViewHeight)
                    .frame(height: webViewHeight)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.all)
//                if webViewHeight == .zero {
//                    // Show `ProgressView` until `HTMLTextView` has set the height.
//                    ProgressView()
//                }
//    
            }.background(Color("Background"))
        }
    }
}

//struct TextPopupElementView: View {
//    let textElement: TextPopupElement
//
//    var body: some View {
//        HTMLTextView(html: <#T##String#>, height: <#T##Binding<CGFloat>#>)
//    }
//}




//struct TestHTMLText: View {
//    var html: String
//
//    @State private var attributedText: AttributedString?
//
//    var body: some View {
//        Group {
//            if let attributedString = attributedText {
//                Text(attributedString).font(.system(size: 16, design: .default))
//            } else {
//                Text(html).font(.system(size: 16, design: .default))
//            }
//        }
//        .onAppear {
//            DispatchQueue.main.async {
//                self.attributedText = attributedStringFromHTML(self.html)
//            }
//        }
//    }
//
//    private func attributedStringFromHTML(_ html: String) -> AttributedString? {
//        if let nsAttributedString = try? NSAttributedString(data: Data(html.utf8), options: [.documentType: NSAttributedString.DocumentType.html], documentAttributes: nil) {
//            return try? AttributedString(nsAttributedString, including: \.uiKit)
//        }
//        return nil
//    }
//}
