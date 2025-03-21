import SwiftUI
import PhotosUI

struct WelcomeScreenView: View {
    @ObservedObject var viewModel: ContentViewModel
    
    var body: some View {
        VStack {
            Spacer()
            
            // Naslov
            Text("OneHand Simple app")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .padding(.bottom, 50)
            
            Spacer()
            
            // Dugmad za izbor ruke
            VStack(spacing: 20) {
                Text("Select your handedness")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.bottom, 10)
                
                HStack(spacing: 20) {
                    HandSelectionButton(
                        title: "Left hand",
                        isSelected: viewModel.selectedHand == .left,
                        action: { viewModel.selectedHand = .left }
                    )
                    
                    HandSelectionButton(
                        title: "Right hand",
                        isSelected: viewModel.selectedHand == .right,
                        action: { viewModel.selectedHand = .right }
                    )
                }
                .padding(.bottom, 20)
                
                // Dugme za izbor slike
                PhotosPicker(selection: $viewModel.selectedItems,
                           maxSelectionCount: 1,
                           matching: .images) {
                    Text("Choose Image")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(width: 200, height: 50)
                        .background(Color.blue)
                        .cornerRadius(15)
                }
                .disabled(viewModel.selectedHand == nil)
                .opacity(viewModel.selectedHand == nil ? 0.5 : 1.0)
            }
            .padding(.bottom, 50)
        }
    }
}

struct HandSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
                .frame(width: 120, height: 44)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.3))
                .cornerRadius(15)
        }
    }
} 