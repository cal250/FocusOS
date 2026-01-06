import SwiftUI

struct DistractionLoggerView: View {
    @ObservedObject var viewModel: SessionViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var distractionDescription: String = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Details")) {
                    TextField("What distracted you?", text: $distractionDescription)
                }
                
                Button(action: {
                    viewModel.logDistraction(description: distractionDescription)
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("Log Distraction")
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.red)
                }
                .disabled(distractionDescription.isEmpty)
            }
            .navigationTitle("Log Distraction")
            .navigationBarItems(trailing: Button("Cancel") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}
