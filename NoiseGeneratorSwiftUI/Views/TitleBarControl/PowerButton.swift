import SwiftUI

struct PowerButton: View {
    
    @Binding var isBypassed: Bool
    
    var body: some View {
        ZStack {
            Toggle(isOn: $isBypassed) {
                if(!isBypassed){
                Image(systemName: "power")
                    .font(.system(size: 14))
                    .foregroundColor(.yellow)
                }
                else{
                 Image(systemName: "power")
                    .font(.system(size: 14))
                    .foregroundColor(.white)
                }
            }
            .toggleStyle(DarkToggleStyle())
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct PowerButton_Previews: PreviewProvider {
    static var previews: some View {
        PowerButton(isBypassed: .constant(true))
        .previewLayout(.fixed(width: 200, height: 200))
    }
}

/*
struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            //.padding(30)
            .contentShape(Circle())
            .background(
                DarkBackground(isHighlighted: configuration.isPressed, shape: Circle())
            )
    }
}
*/

struct DarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(5)
                .contentShape(Circle())
        }
        .background(
            DarkBackground(isHighlighted: configuration.isOn, shape: Circle())
        )
        .animation(Animation.easeOut.speed(2.5))
    }
}

struct DarkBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S

    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                    .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 2, x: 2, y: 2)
                    .shadow(color: Color.darkEnd, radius: 2, x: -2, y: -2)

            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(Color.darkEnd, lineWidth: 4))
                    //.shadow(color: Color.darkStart, radius: 5, x: -1, y: -1)
                    //.shadow(color: Color.darkEnd, radius: 5, x: 1, y: 1)
            }
        }
    }
}

extension LinearGradient {
    init(_ colors: Color...) {
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

