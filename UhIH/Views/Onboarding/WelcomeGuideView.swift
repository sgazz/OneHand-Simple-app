import SwiftUI

struct WelcomeGuideView: View {
    @ObservedObject var viewModel: WelcomeGuideViewModel
    @State private var currentSectionIndex = 0
    
    var body: some View {
        if viewModel.isShowingGuide {
            ZStack {
                Color.black.opacity(0.5)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    // Naslov
                    Text("Dobrodošli u\nOneHand Simple App")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .minimumScaleFactor(0.8)
                        .padding(.top, 35)
                        .padding(.bottom, 25)
                        .padding(.horizontal, 25)
                    
                    // Sadržaj sekcije
                    VStack(spacing: 12) {
                        Text(WelcomeGuideSection.sections[currentSectionIndex].title)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)
                            .padding(.bottom, 8)
                        
                        Text(WelcomeGuideSection.sections[currentSectionIndex].content)
                            .font(.system(size: 17))
                            .foregroundColor(.white.opacity(0.9))
                            .multilineTextAlignment(.center)
                            .lineSpacing(4)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 25)
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                    
                    // Dugmad
                    VStack(spacing: 20) {
                        // Checkbox za "Always show"
                        HStack(spacing: 10) {
                            Image(systemName: viewModel.showAlways ? "checkmark.square.fill" : "square")
                                .font(.system(size: 20))
                                .foregroundColor(.white)
                                .onTapGesture {
                                    viewModel.showAlways.toggle()
                                }
                            Text("Always show this screen")
                                .font(.system(size: 16))
                                .foregroundColor(.white.opacity(0.9))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 5)
                        
                        // Dugmad za navigaciju
                        HStack(spacing: 20) {
                            Button("Skip") {
                                viewModel.dismissGuide()
                            }
                            .font(.system(size: 17, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 44)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            
                            Button(currentSectionIndex == WelcomeGuideSection.sections.count - 1 ? "Got it" : "Next") {
                                if currentSectionIndex == WelcomeGuideSection.sections.count - 1 {
                                    viewModel.dismissGuide()
                                } else {
                                    withAnimation {
                                        currentSectionIndex += 1
                                    }
                                }
                            }
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 100, height: 44)
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.bottom, 30)
                    }
                    .padding(.horizontal, 25)
                }
                .frame(width: 320, height: 400)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.4, green: 0.2, blue: 0.8),
                            Color(red: 0.6, green: 0.3, blue: 0.9)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(radius: 20)
            }
            .transition(.opacity)
        }
    }
} 