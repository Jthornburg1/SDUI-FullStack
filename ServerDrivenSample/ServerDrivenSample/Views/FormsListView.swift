import SwiftUI
import Playgrounds

struct FormsListView: View {
    @State var viewModel = FormsViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.forms, id: \.id) { form in
                NavigationLink(value: form) {
                    VStack(alignment: .leading) {
                        Text(form.title)
                            .font(.system(size: 14))
                        Text(form.description)
                            .font(.system(size: 12))
                            .foregroundStyle(Color.gray)
                    }
                }
            }
            .navigationTitle("Forms")
            .navigationDestination(for: FormSummary.self, destination: { form in
                FormDetailView(form: form)
            })
            .task {
                await viewModel.callFetchForms()
            }
        }
    }
}

#Preview {
    FormsListView()
}
