import SwiftUI

struct TextPicker: View {
    
    @State private var presetIndex = 4
    @State var selected = "Large Room"
    
    var presets = ["Cathedral", "Large Hall", "Large Hall 2",
    "Large Room", "Large Room 2", "Medium Chamber",
    "Medium Hall", "Medium Hall 2", "Medium Hall 3",
    "Medium Room", "Plate", "Small Room"]
    
    var body: some View {
        VStack{

                Text("SELECT A PRESET")
                    .font(.system(size: 36))
                    .bold()
                    .foregroundColor(Color.white)
                    .frame(minWidth: 0,
                           maxWidth: .infinity,
                           maxHeight: .infinity)

                Picker(selection: self.$presetIndex, label: Text("Preset")){
                    ForEach(0 ..< self.presets.count){ n in
                            Text(self.presets[n])
                                .font(.system(size: 26))
                                .bold()
                                .foregroundColor(Color.white)
                                .tag(n)
                                
                    }
                }
                .frame(minWidth: 0,
                       maxWidth: .infinity,
                       minHeight: 150)
            
                .labelsHidden()
                .border(Color.white, width: 1)
            
            HStack {
                Button(action: {
                        print("Cancel tapped!")
                    }) {
                        HStack(alignment: .center) {
                            Image(systemName: "nosign")
                                .font(.system(size: 22))
                            Text("Cancel")
                                .fontWeight(.semibold)
                                .font(.system(size: 22))
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .foregroundColor(.white)

                }
                .border(Color.white, width: 1)
                
                Button(action: {
                        print("Update tapped!")
                    }) {
                        HStack(alignment: .center) {
                            Image(systemName: "arrow.clockwise.circle")
                                .font(.system(size: 22))
                            Text("Use Preset")
                                .fontWeight(.semibold)
                                .font(.system(size: 22))
                        }
                        .frame(minWidth: 0, maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                        .foregroundColor(.white)

                }
            .border(Color.white, width: 1)
            }
            Spacer()
                
        }
        .padding()
        .background((Color.black))
        .border(Color.white, width: 6)
    
                /*
                Color.gray.edgesIgnoringSafeArea(.all)
                VStack{

                    Text("SELECT A NEW PRESET")
                        .font(.system(size: 22))
                        .bold()
                        .foregroundColor(Color.white)
                    //Text(self.selected).padding().foregroundColor(.white)
                    //Text("Index: \(self.presetIndex)").padding().foregroundColor(.white)
                        CustomPicker(selected: self.$selected,
                                     selectedIndex: self.$presetIndex,
                                     data: myData,
                                     frame: geometry.frame(in: .local))

                }
 */
                //.frame(width:geometry.size.width)
        
        /*
        VStack{
            
            ScrollView(.vertical, showsIndicators: false){
                VStack{
                    Picker(selection: $presetIndex, label: Text("Preset")){
                        ForEach(0 ..< presets.count){ n in
                            HStack {
                                //Text("Preset \(n): ")
                                Text(self.presets[n])
                                Spacer()
                                }.tag(n)
                            //.frame(height:40)
                        }
                    }
                }
                
            }.background(Color.white)
            .padding()
        }
            */
        
        
        /*
        NavigationView {
            ZStack{
                Color.red
            }.navigationBarTitle("Hello World")
            
            Form {
                Section {
                    Picker(selection: $presetIndex, label: Text("Preset")){
                            ForEach(0 ..< presets.count){
                                Text(self.presets[$0]).tag($0)
                            }
                    }
                }
            }
            
        }
         */
    }
}

struct TextPicker_Previews: PreviewProvider {
    static var previews: some View {
        TextPicker()
        .previewLayout(.fixed(width: 400, height: 330))
    }
    
}

struct GradientBackgroundStyle: ButtonStyle {
 
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .foregroundColor(.white)
            .background(LinearGradient(gradient: Gradient(colors: [Color("DarkGreen"), Color("LightGreen")]), startPoint: .leading, endPoint: .trailing))
            .cornerRadius(40)
            .padding(.horizontal, 20)
    }
}


struct CustomPicker: UIViewRepresentable{
    
    @Binding var selected: String
    @Binding var selectedIndex: Int
    var data: [String]
    var frame: CGRect
    
    func makeCoordinator() -> CustomPicker.Coordinator{
        return CustomPicker.Coordinator(parent1: self, data1: data, frame1: frame)
    }
    
    func makeUIView(context: UIViewRepresentableContext<CustomPicker>) -> UIPickerView{
        let picker = UIPickerView()
        //picker.frame = frame
        picker.dataSource = context.coordinator
        picker.delegate = context.coordinator
        picker.backgroundColor = .white
        
        return picker
    }
    
    func updateUIView(_ uiView: UIPickerView, context: UIViewRepresentableContext<CustomPicker>) {
        //uiView.frame = frame
    }
    
    class Coordinator: NSObject, UIPickerViewDelegate, UIPickerViewDataSource{
        var parent: CustomPicker
        var data: [String]
        var frame: CGRect
        
        init(parent1 : CustomPicker, data1: [String], frame1: CGRect){
            parent = parent1
            data = data1
            frame = frame1
        }
        
        func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
            
            return data.count
        }
        
        func numberOfComponents(in pickerView: UIPickerView) -> Int {
            
            return 1
        }
        
        /*
        func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
            return data[row]
        }
         */
        
        func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
            
            //pickerView.frame = frame
            
            let view = UIView(frame: CGRect(x:0, y:0, width: pickerView.frame.width, height: 50))
            
            let label = UILabel(frame: CGRect(x:0, y:0, width: pickerView.frame.width, height: view.bounds.height))
            
            label.text = data[row]
            label.textColor = .white
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 22, weight: .bold)
            
            view.backgroundColor = .black
            
            view.addSubview(label)
            
            view.clipsToBounds = true
            view.layer.cornerRadius = view.bounds.height / 2
            
            view.layer.borderWidth = 2.5
            view.layer.borderColor = UIColor.white.cgColor
            
            return view
        }
        
        func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
            return pickerView.frame.width
        }
        
        func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
            return 55
        }
        
        func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
            self.parent.selected = data[row]
            self.parent.selectedIndex = row
        }
        
    }
}


