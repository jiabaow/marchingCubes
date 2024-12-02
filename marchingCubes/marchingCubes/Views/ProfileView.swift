import SwiftUI
import UIKit

struct ProfileView: View {
    @AppStorage("isAuthenticated") private var isAuthenticated = false
    @AppStorage("currentUser") private var currentUser = ""
    @EnvironmentObject var viewModel: ProjectViewModel
    @ObservedObject var userViewModel: UserViewModel
    @State private var avatarImage: UIImage? = nil
    @State private var userName: String = "Peter Johnson"
    @Environment(\.modelContext) var modelContext

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Sign Out Button
                HStack {
                    Button(action: {
                        signOut()
                    }) {
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                            .padding()
                            .background(Color.gray.opacity(0.2))
                            .clipShape(Circle())
                    }
                    Spacer()
                }
                .padding(.trailing, 20)
                .padding(.top, 20)
                
                // User avatar and name
                VStack {
                    if let avatarImage = avatarImage {
                        Image(uiImage: avatarImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 120, height: 120)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    } else {
                        Circle()
                            .fill(Color.gray)
                            .frame(width: 120, height: 120)
                            .overlay(Circle().stroke(Color.white, lineWidth: 4))
                            .shadow(radius: 10)
                    }

                    Text(userName)
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.top, 20)

                // My Favorites section
                VStack(alignment: .leading, spacing: 16) {
                    Text("My Favorites")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            ForEach(viewModel.models.filter { $0.isFavorite }, id: \.id) { project in
                                VStack {
                                    // AsyncImage for loading image from URL
                                    if !project.image.isEmpty, let url = get3DModelURL(filename: project.image) {
                                        AsyncImage(url: url) { phase in
                                            switch phase {
                                            case .empty:
                                                // You can show a placeholder image or spinner while loading
                                                ProgressView()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            case .success(let image):
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            case .failure:
                                                // Fallback to a default image if loading fails
                                                Image(systemName: "exclamationmark.triangle.fill")
                                                    .resizable()
                                                    .frame(width: 100, height: 100)
                                                    .cornerRadius(10)
                                            @unknown default:
                                                EmptyView()
                                            }
                                        }
                                    } else {
                                        if let image = UIImage(named: project.image) {
                                            Image(uiImage: image)
                                                .resizable()
                                                .aspectRatio(contentMode: .fill)
                                                .frame(width: 150, height: 150)
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                        } else {
                                            Rectangle()
                                                .fill(Color.gray)
                                                .frame(width: 150, height: 150)
                                                .cornerRadius(12)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .stroke(Color.white, lineWidth: 2)
                                                )
                                        }
                                    }
                                    
                                    Text(project.title)
                                        .font(.caption)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Spacer()
            }
            .padding()
            .background(Color.white) // Fixed background color
            .onAppear {
                Task {
                    await loadUserData()
                }
            }
        }
    }

    private func loadUserData() async {
        // Use the existing userViewModel to fetch and update data
        await userViewModel.fetchUserData(idToken: currentUser)
        userName = userViewModel.username ?? "Peter Johnson"
        
        let profileImageData = userViewModel.profileImage ?? ""
        let loadedImage = loadSVGImage(from: profileImageData)
        avatarImage = UIImage(data: loadedImage?.pngData()! ?? Data())
    }
    
    private func signOut() {
        self.isAuthenticated = false
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        let mockProjectViewModel = ProjectViewModel() // Mock or sample data
        let mockUserViewModel = UserViewModel(userModel: UserModel(
            id: "123",
            email: "mock@example.com",
            username: "mockuser",
            profile_image: "PHN2ZyB4bWxucz0iaHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmciIHZpZXdCb3g9IjAgMCA5ODAgOTgwIiBmaWxsPSJub25lIiBzaGFwZS1yZW5kZXJpbmc9ImF1dG8iIHdpZHRoPSIxMjAiIGhlaWdodD0iMTIwIj48bWV0YWRhdGEgeG1sbnM6cmRmPSJodHRwOi8vd3d3LnczLm9yZy8xOTk5LzAyLzIyLXJkZi1zeW50YXgtbnMjIiB4bWxuczp4c2k9Imh0dHA6Ly93d3cudzMub3JnLzIwMDEvWE1MU2NoZW1hLWluc3RhbmNlIiB4bWxuczpkYz0iaHR0cDovL3B1cmwub3JnL2RjL2VsZW1lbnRzLzEuMS8iIHhtbG5zOmRjdGVybXM9Imh0dHA6Ly9wdXJsLm9yZy9kYy90ZXJtcy8iPjxyZGY6UkRGPjxyZGY6RGVzY3JpcHRpb24+PGRjOnRpdGxlPkxvcmVsZWk8L2RjOnRpdGxlPjxkYzpjcmVhdG9yPkxpc2EgV2lzY2hvZnNreTwvZGM6Y3JlYXRvcj48ZGM6c291cmNlIHhzaTp0eXBlPSJkY3Rlcm1zOlVSSSI+aHR0cHM6Ly93d3cuZmlnbWEuY29tL2NvbW11bml0eS9maWxlLzExOTg3NDk2OTMyODA0Njk2Mzk8L2RjOnNvdXJjZT48ZGN0ZXJtczpsaWNlbnNlIHhzaTp0eXBlPSJkY3Rlcm1zOlVSSSI+aHR0cHM6Ly9jcmVhdGl2ZWNvbW1vbnMub3JnL3B1YmxpY2RvbWFpbi96ZXJvLzEuMC88L2RjdGVybXM6bGljZW5zZT48ZGM6cmlnaHRzPlJlbWl4IG9mIOKAnkxvcmVsZWnigJ0gKGh0dHBzOi8vd3d3LmZpZ21hLmNvbS9jb21tdW5pdHkvZmlsZS8xMTk4NzQ5NjkzMjgwNDY5NjM5KSBieSDigJ5MaXNhIFdpc2Nob2Zza3nigJ0sIGxpY2Vuc2VkIHVuZGVyIOKAnkNDMCAxLjDigJ0gKGh0dHBzOi8vY3JlYXRpdmVjb21tb25zLm9yZy9wdWJsaWNkb21haW4vemVyby8xLjAvKTwvZGM6cmlnaHRzPjwvcmRmOkRlc2NyaXB0aW9uPjwvcmRmOlJERj48L21ldGFkYXRhPjxtYXNrIGlkPSJ2aWV3Ym94TWFzayI+PHJlY3Qgd2lkdGg9Ijk4MCIgaGVpZ2h0PSI5ODAiIHJ4PSIwIiByeT0iMCIgeD0iMCIgeT0iMCIgZmlsbD0iI2ZmZiIgLz48L21hc2s+PGcgbWFzaz0idXJsKCN2aWV3Ym94TWFzaykiPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDEwIC02MCkiPjxwYXRoIGZpbGwtcnVsZT0iZXZlbm9kZCIgY2xpcC1ydWxlPSJldmVub2RkIiBkPSJNNDY2IDE5NmgxYzEwIDIgMjEgNCAzMCA4IDExLTUgMjItOCAzNC04IDIxIDAgNDIgMyA2MiAxMWwyMSAxMWE5OTQgOTk0IDAgMCAwIDIyIDEyaDFjMTAgNiAxOCAxMyAyNiAyMWEyMDIgMjAyIDAgMCAxIDU2IDExN2wxIDJjMCAyIDAgMyAyIDQgMTYgMTMgMjYgMzIgMzIgNTIgNCAxNCAyIDMwLTMgNDQtNiAxNy0xNiAzMi0yOSA0NGwtMSAyIDkgOWM3IDQgMTIgMTAgMTggMTUgMTcgMTkgMzEgNDIgMzYgNjcgMyAxMyAzIDI3IDAgNDEtNSAxOC0xNyAzMy0zMSA0My04IDYtMTYgMTAtMjQgMTQgMyA0IDYgOSA3IDEzIDQgMTIgMyAyNS0yIDM2cy0xMyAxOS0yMiAyNmwtMjAgMTFjLTQgMS05IDItMTMtMS0yLTEtMi0zLTEtNXYtMWwzLTE3Yy0xMyAxNi0zMCAyOC00OSAzNWExMzggMTM4IDAgMCAxLTU3IDZsLTExLTFjLTkgMC0xNi0yLTI0LTRsLTktMmE1NTIgNTUyIDAgMCAwLTE1OC0xNGwtNCAyLTIgMmMtMjEgMTctNDggMjQtNzQgMjYtMTEgMS0yMSAwLTMyLTEtMTgtMi0zNy03LTUyLTE3bC0yLTEtNC0yYy0xMi0xLTI0LTYtMzQtMTMtOS02LTE2LTE2LTIwLTI2LTYtMTItOS0yNC04LTM3IDEtMTggOS0zNiAyMi00OC00LTUtOS05LTEyLTE1LTEzLTE4LTIwLTQxLTIzLTY0LTEtMTUgMC0zMSAzLTQ2YTE1MyAxNTMgMCAwIDEgNjctOTFjLTkgMy0xNyA5LTI1IDE0LTEzIDktMjUgMjEtMzQgMzQtNiA4LTExIDE2LTE0IDI2bC0yIDMtMiA2Yy0yLTEtMi0zLTItNS0xLTYgMC0xMiAyLTE3IDUtMjIgMTgtNDEgMzUtNTYgMTQtMTMgMzEtMjIgNDktMjdsMS0xYTI2NSAyNjUgMCAwIDEgNDktMTQ4IDIxNyAyMTcgMCAwIDEgMjExLTg5Wm0yOTMgMzg4YzUgOSA5IDIwIDExIDMxIDIgMTAgMSAyMS0yIDMxLTUgMTQtMTUgMjctMjcgMzYgMTMtMTggMjAtNDAgMjEtNjIgMS0xMiAwLTI0LTItMzZoLTFaTTE5MCA2ODljLTctMi0xNC03LTIwLTExYTc3IDc3IDAgMCAwLTE1IDQ5YzIgMjEgMTQgNDIgMzMgNTItOS0xMy0xNS0yNy0xNS00My0xLTEyIDItMjUgOC0zNmw3LTkgMi0yWiIgZmlsbD0iIzAwMDAwMCIvPjxwYXRoIGQ9Ik00OTUgMjM0YzI4IDEgNTYgNiA4NCAxNWEyMDEgMjAxIDAgMCAxIDEwMCA2NWMxOSAyNSAzMSA1NSAzNSA4NmEzNjEgMzYxIDAgMCAxIDIgMTAxbC01IDM0LTQgMjBjLTEgMi0xIDItMyAyLTItNC0yLTgtMi0xMi0xLTE1IDEtMjkgMi00NCAxLTI0IDMtNDggMS03MmwtNi00NWMtNy0yOC0yMC01NC00MC03NS0xOC0xOC00MC0zMy02My00My0yMi05LTQ0LTE1LTY3LTE5LTE4LTMtMzYtNC01NC00YTI3NyAyNzcgMCAwIDAtMTI4IDI5Yy0xMyA5LTI1IDIwLTM1IDMyYTI3NiAyNzYgMCAwIDAtNTUgMTM5Yy0xIDI0IDAgNDcgOCA3MGw3IDE1IDEyIDEgMSAzYy0zIDItNyAyLTExIDMtMTAgMi0yMCA2LTI5IDEyLTcgNS0xNCAxMS0xOCAxOS01IDEwLTMgMjItMSAzMyA1IDE5IDE3IDM3IDMzIDQ5IDExIDkgMjUgMTQgMzkgMTYgMTAgMiAyMCAwIDMwLTEgNSA0IDggMTIgMTEgMTdsMTggMjdhMTM2IDEzNiAwIDAgMCA2NiA1MGMyMiA5IDQ1IDE0IDY4IDE5bDQxIDggMTcgNXY0aC0xMmE1MzUgNTM1IDAgMCAxLTY3LTggMjU1IDI1NSAwIDAgMS04NC0zM2MtMTEtNy0yMS0xNi0yOS0yN2EyMTQgMjE0IDAgMCAxLTE2IDEyM2MtMTUgMjctNDAgNDgtNzAgNTctMyAxLTcgMi0xMCAxLTIgMC0yLTEtMi0zIDEtMyA0LTUgNi02IDEyLTggMjYtMTQgMzgtMjMgMTMtMTEgMjQtMjMgMzEtMzggNi0xNSAxMC0zMiAxMi00OSAyLTEzIDMtMjYgMi00MGwtNC0zOC0xOC0zNi0xOSA0YTg4IDg4IDAgMCAxLTc1LTM4IDkzIDkzIDAgMCAxLTIwLTU4YzAtOSAzLTE4IDgtMjVzMTItMTMgMTktMTdjNS00IDEyLTYgMTgtOGwtOS0yNGMtNS0yMi01LTQ1LTItNjdhMjkyIDI5MiAwIDAgMSA2My0xNDljOS0xMCAxOC0xOSAyOS0yNiA3LTQgMTQtNSAyMC05IDQzLTE5IDkwLTI1IDEzNy0yMloiIGZpbGw9IiMwMDAiLz48cGF0aCBkPSJNNDc1IDI0M2EyNzYgMjc2IDAgMCAxIDEyMSAyM2MyMyAxMCA0NSAyNSA2MyA0MyAyMCAyMSAzMyA0NyA0MCA3NWw2IDQ1YzIgMjQgMCA0OC0xIDcyLTEgMTUtMyAyOS0yIDQ0IDAgNCAwIDggMiAxMmwtMSAyMGMtMiA1LTIgMTAtMiAxNi0yIDI0LTIgNDktNiA3NC0xIDEyLTMgMjUtOCAzNi0zIDktOCAxNy0xNSAyNC0xMiAxMy0yNyAyNC00MyAzMy0xOSAxMS0zOSAxNi01OCAyNC01IDItMTAgNC0xMyA4IDggMSAxNSAwIDIzLTItNSAxMi02IDI0LTYgMzYgMCA1LTEgMTEgMSAxNiAzIDUgOCA5IDEzIDEybDM1IDEzYzIyIDggNDMgMTggNjUgMjcgMiA0IDUgNyA2IDEyIDYgMTEgNyAyMyAzIDM1LTUgMTMtMTUgMjQtMjcgMzEtMTYgMTEtMzYgMTktNTUgMjRhNDk0IDQ5NCAwIDAgMS0yMzUtN2MtMjAtNy00MC0xNC01OC0yNC0xNC04LTI5LTE4LTQwLTMxLTYtOC0xMS0xOS0xMi0yOWExMjIgMTIyIDAgMCAwIDg2LTEwN2M0LTI0IDQtNDkgMC03MyA4IDExIDE4IDIwIDI5IDI3bDI3IDE0YTMzMSAzMzEgMCAwIDAgMTI0IDI3aDEydi00bC0xNy01LTQxLThjLTIzLTUtNDYtMTAtNjgtMTktMTMtNi0yNy0xMy0zOS0yMS0xMC05LTE5LTE4LTI3LTI5bC0xOC0yN2MtMy01LTYtMTMtMTEtMTctMTAgMS0yMCAzLTMwIDEtMTQtMi0yOC03LTM5LTE2YTk0IDk0IDAgMCAxLTMzLTQ5Yy0yLTExLTQtMjMgMS0zMyA0LTggMTEtMTQgMTgtMTkgOS02IDE5LTEwIDI5LTEyIDQtMSA4LTEgMTEtM2wtMS0zLTEyLTEtNy0xNWMtOC0yMy05LTQ2LTctNzBhMjc2IDI3NiAwIDAgMSA1NC0xMzljMTAtMTIgMjItMjMgMzUtMzJhMjc3IDI3NyAwIDAgMSAxMjgtMzBaIiBmaWxsPSIjZmZmZmZmIi8+PHBhdGggZD0iTTI2MCA1NzFjNCAwIDcgMCAxMSAyIDUgMSAxMSA0IDE0IDggMiAzIDIgNyAwIDEwLTUgNi0xMiAxMC0xNiAxNiA2IDQgMTQgNiAyMSA5IDQgMSA4IDMgMTEgNmwxIDMtOC0yLTI0LTdjLTQtMS04LTMtOS03LTEtMyAxLTcgMy0xMGwxNS0xM2MtNC03LTE1LTgtMTktMTVaTTcwMyA1NzdsMiAzIDIgMTZhNDgzIDQ4MyAwIDAgMS0yIDg5Yy0yIDExLTUgMjMtMTAgMzNhMTk4IDE5OCAwIDAgMS0xMDYgNzFjLTEgMTQtMyAzMS0yIDQ3bDUgNWM4IDYgMTggOSAyNyAxMmE0NTEgNDUxIDAgMCAxIDY4IDI4YzcgNCAxMyA5IDE4IDE1LTUgMS0xMC0xLTE2LTItMjItOS00My0xOS02NS0yN2wtMzUtMTNjLTUtMy0xMC03LTEzLTEyLTItNS0xLTExLTEtMTYgMC0xMiAxLTI0IDYtMzYtOCAyLTE1IDMtMjMgMiAzLTQgOC02IDEzLTggMTktOCAzOS0xMyA1OC0yNCAxNi05IDMxLTIwIDQzLTMzIDctNyAxMi0xNSAxNS0yNCA1LTExIDctMjQgOC0zNiA0LTI1IDQtNTAgNi03NCAwLTYgMC0xMSAyLTE2WiIgZmlsbD0iIzAwMCIvPjxwYXRoIGQ9Ik00NTUgNDY4YzE0IDAgMjcgNSAzOCAxMyAxNSAxMCAyNiAyNSAzMCA0M3YxNGMtMSAxLTIgMi00IDEtMy0zLTUtOC03LTEyLTgtMTQtMTgtMjgtMzItMzYtMTAtNi0yMi04LTMzLTYgNyAxMiAxMSAyNiAxMSA0MCAwIDktNCAxNi04IDI0LTIgMi01IDEtNyAxLTcgMC0xMy0yLTIwLTQtMy0yLTgtNC0xMC04bC0xLTE0IDQtMTktNiA4Yy0zIDQtMTAgNC0xMyAwLTMtMy0zLTgtMS0xMiA2LTggMTMtMTYgMjItMjIgMTEtOCAyNC0xMSAzNy0xMVpNNjg0IDQ4OGMyIDEgMyAzIDAgNGwtMTUgOGM1IDAgMTAtMSAxNSAyIDMgMSA2IDUgNiA5LTQgNC05IDctMTUgNy0xNSAwLTMwIDMtNDQgMTAtMyAxLTggMi0xMS0xLTQtMy00LTktMi0xMiAyLTQgNS02IDgtOGw0NS0xN2M0LTEgOS0zIDEzLTJaIiBmaWxsPSIjMDAwMDAwIi8+PHBhdGggZD0iTTQ5NiAzNzVjMTAgMSAyMCA0IDI3IDExIDMgMyA1IDcgNiAxMS0xMS01LTIyLTYtMzMtNi02IDEtMTIgNC0xNyA3LTIzIDEyLTQzIDI5LTY2IDQxbC0yMCAxNC0xMSAxMWMtMS01IDEtMTAgMi0xNCA0LTEwIDExLTE3IDE5LTI0bDI0LTE3YzEzLTkgMjctMTkgNDEtMjYgOS00IDE4LTggMjgtOFpNNzAxIDQxMWMtNiAzLTExIDMtMTcgNC01IDEtMTAgMy0xNCA2LTkgNy0xNyAxNS0yNCAyNC05IDEwLTE3IDE4LTI5IDI0bC03IDJjLTIgMS00IDAtNiAyLTQgNS00IDEzLTkgMTctMiAwLTItMi0yLTN2LTEzYzEtNSAzLTEyIDctMTZzOS00IDEzLThsMTUtMTAgMjMtMThjNi01IDEzLTEwIDIwLTEzIDEwLTMgMjEtMyAzMCAyWiIgZmlsbD0iIzAwMDAwMCIvPjxwYXRoIGQ9Ik02MDkgNjAyYzEgOS00IDE2LTkgMjMtNCAzLTkgNi0xNSA2cy0xMy0zLTE5LTVjLTQtMi04LTMtMTEtNmw1LTRjOS0xIDE3IDMgMjUgNCA0IDAgNy0zIDktNiA1LTUgOS0xMCAxNS0xMloiIGZpbGw9IiMwMDAwMDAiLz48cGF0aCBkPSJtNjM2IDY1MS03IDdjLTcgOC0xNCAxNi0yMyAyMy04IDctMTcgMTMtMjcgMTYtMTEgNC0yMyA0LTM1IDMtMTYtMi0zMS01LTQ1LTEybC0xMi03Yy0xLTItMS00IDEtNXM2IDAgOCAxYzEyIDQgMjQgOCAzNyA5IDE3IDIgMzQgMiA1MC0zIDgtMiAxNS02IDIxLTEwbDI0LTE3IDgtNVoiIGZpbGw9IiMwMDAwMDAiLz48cGF0aCBmaWxsLXJ1bGU9ImV2ZW5vZGQiIGNsaXAtcnVsZT0iZXZlbm9kZCIgZD0iTTQ2OCAxOTZhMjE4IDIxOCAwIDAgMC0yMzQgMTIyIDMyMyAzMjMgMCAwIDAtMjUgMTg2bDQgMTljMSAzIDMgNiA1IDZsNCAxaDFjNSA2IDEyIDEwIDIwIDEyIDEyIDQgMjYgNCAzOCAyLTMgMTYgMSAzNCA3IDQ5IDUgMTIgMTMgMjUgMjMgMzRhNjcgNjcgMCAwIDAgNTEgMTRjNS0xIDktNCAxMy04di0xbDItNWgtM2MtMyAwLTUgMC04LTItMTEtNi0xOS0xNy0yNS0yOC0xMC0yMC0xNS00My0xNS02NSAxMy02IDI0LTE2IDMzLTI3bDctNSA0LTJjOS02IDE3LTE0IDI1LTIyIDE3LTIwIDMwLTQzIDM5LTY3YTQ0MyA0NDMgMCAwIDAgMTYtNjNjNC0yMCA4LTQxIDE3LTYwYTE4NSAxODUgMCAwIDEgMzQgMWwxMiAxYzMtMSA0LTQgNC03IDAtNS0zLTEwLTYtMTRhMjcyIDI3MiAwIDAgMSA0NSAyNmMyIDIgNSAzIDcgMmExNzIgMTcyIDAgMCAwIDI2LTEzbDYtNCAxNC03Yy0zIDUtNyAxMi03IDE4IDAgMyAzIDUgNiA1IDExIDEgMjEtMSAzMi00bDQtMWM0LTEgOCAyIDExIDQgOSA5IDE1IDIyIDE2IDM0YTExOCAxMTggMCAwIDEgMCAzNWwtMSAxMS0xIDE1LTIgMzdjMiAxNiA4IDMyIDIwIDQzIDkgOSAyMiAxMiAzNCA5IDYtMiAxMi02IDE2LTEwIDUtNCA3LTkgNy0xNmwtMTEgNC0xNCA0di04YzQtMyA4LTcgMTAtMTFsLTItOS0xLTctMy0yMy0zLTI1LTEtN2MtMi0xNC00LTI3LTktNDFhMTYyIDE2MiAwIDAgMC00Mi02OGMtNi00LTExLTctMTgtOWExMzYgMTM2IDAgMCAwLTM5LTM2Yy0xNy04LTM0LTE0LTUyLTE3LTE1LTItMzItMy00NiAxbC0xNiA1Yy05LTQtMTktNi0yOS04Wm0tMjAgMTE1YzMtOCA1LTE3IDEwLTI1LTE0IDEtMjcgMy00MSA2LTcgMTMtMTQgMjctMTggNDFhMjMyIDIzMiAwIDAgMC0xMCA3MWMtMiAyMS0zIDQzLTkgNjMgMTktMjAgMzQtNDUgNDItNzEgNi0xNSAxMC0zMCAxNC00NiA0LTEzIDctMjYgMTItMzh2LTFaIiBmaWxsPSIjMDAwMDAwIi8+PC9nPjxnIHRyYW5zZm9ybT0idHJhbnNsYXRlKDEwIC02MCkiPjwvZz48L2c+PC9zdmc+",
            projects: ["project1", "project2"],
            favorites: ["fav1", "fav2"],
            created_timestamp: 1700000000
        ))
        ProfileView(userViewModel: mockUserViewModel)
            .environmentObject(mockProjectViewModel)
    }
}
