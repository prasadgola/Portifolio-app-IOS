import SwiftUI

struct ReadTextScreen: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    ImageSliderSection()
                    AboutMeSection()
                    EducationSection()
                    ProjectsSection()
                    ConnectMeSection()
                    ContactFormSection()
                }
            }
            .background(Color.black)
            .navigationTitle("AgentShelf")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Image Slider

struct ImageSliderSection: View {
    @State private var currentPage = 0

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $currentPage) {
                PostSlide1().tag(0)
                PostSlide2().tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 450)

            HStack(spacing: 8) {
                ForEach(0..<2, id: \.self) { index in
                    Circle()
                        .fill(index == currentPage ? Color.amber : Color.white.opacity(0.5))
                        .frame(width: index == currentPage ? 10 : 8,
                               height: index == currentPage ? 10 : 8)
                }
            }
            .padding(.bottom, 16)
        }
    }
}

struct PostSlide1: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // TODO: Replace with Image("post1") when image is available
            Color(white: 0.15)
                .frame(height: 450)

            VStack(alignment: .leading, spacing: 8) {
                Text("Hello!")
                    .foregroundColor(.amber)
                    .font(.title3)
                    .kerning(2)

                Group {
                    Text("I'm \n").foregroundColor(.white) +
                    Text("Basavaprasad\nGola").foregroundColor(.amber)
                }
                .font(.system(size: 50, weight: .bold))
                .lineSpacing(4)

                Text("Developer")
                    .foregroundColor(.white)
                    .font(.system(size: 32))
            }
            .padding(15)
        }
    }
}

struct PostSlide2: View {
    var body: some View {
        ZStack(alignment: .leading) {
            // TODO: Replace with Image("post2") when image is available
            Color(white: 0.12)
                .frame(height: 450)

            VStack(alignment: .leading, spacing: 8) {
                Text("Hello!")
                    .foregroundColor(.amber)
                    .font(.title3)
                    .kerning(2)

                Group {
                    Text("Graduated from \n").foregroundColor(.white) +
                    Text("University of Texas\nat Arlington").foregroundColor(.amber)
                }
                .font(.system(size: 40, weight: .bold))
                .lineSpacing(4)

                Text("Texas, United States")
                    .foregroundColor(.white)
                    .font(.system(size: 32))
            }
            .padding(15)
        }
    }
}

// MARK: - About Me

struct AboutMeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("About")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white.opacity(0.05))
            Text("About Me")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)

            VStack(spacing: 0) {
                AboutInfoRow(label: "Name", value: "Basavaprasad Mallikarjun Gola")
                AboutInfoRow(label: "Address", value: "Plano, Texas, United States of America")
                AboutInfoRow(label: "Zip code", value: "75074")
                AboutInfoRow(label: "Email", value: "basavaprasadgolacs@gmail.com")
                AboutInfoRow(label: "Phone", value: "+1 (682) 266 - 3588")
                AboutInfoRow(label: "Date of birth", value: "July - 14th - 1998")
            }
            .padding(.top, 24)

            Button(action: { }) {
                Text("Download CV")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.amber)
                    .cornerRadius(4)
            }
            .padding(.top, 24)
        }
        .padding(20)
    }
}

struct AboutInfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack(alignment: .top) {
            Text("\(label) :")
                .foregroundColor(.amber)
                .fontWeight(.bold)
                .font(.system(size: 16))
                .frame(width: 110, alignment: .leading)
            Text(value)
                .foregroundColor(.white.opacity(0.8))
                .font(.system(size: 16))
        }
        .padding(.vertical, 10)
    }
}

// MARK: - Education

struct EducationSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Education")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white.opacity(0.05))
            Text("Education")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)

            VStack(spacing: 0) {
                EducationCard(year: "2021 - 2023", degree: "Master Degree of Computer Science and Engineering", institution: "University of Texas at Arlington", subjects: "Database Systems, Machine Learning, Software Engineering")
                EducationCard(year: "2016 - 2020", degree: "Bachelor's Degree of Electronics and Communication", institution: "Dayananda Sagar College of Engineering", subjects: "Logic Design, Embedded System Design, Advanced Digital Switching, Wireless and Mobile Communications, Cryptography and Network Security")
                EducationCard(year: "2014 - 2016", degree: "Pre University College of Karnataka Board", institution: "Sharanabasaveshwar Residential PU College", subjects: "Physics, Chemistry, Electronics")
                EducationCard(year: "2004 - 2014", degree: "Secondary School Leaving Certificate", institution: "Sharanabasaveshwar Residential Public School", subjects: "Science, Social-Science, Mathematics, English, Kannada, Hindi")
            }
            .padding(.top, 24)

            HStack {
                Spacer()
                Button(action: { }) {
                    Text("Download CV")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color.amber)
                        .cornerRadius(4)
                }
                Spacer()
            }
            .padding(.top, 24)
        }
        .padding(20)
    }
}

struct EducationCard: View {
    let year: String
    let degree: String
    let institution: String
    let subjects: String

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(year).foregroundColor(.amber).font(.system(size: 16, weight: .bold))
            Text(degree).foregroundColor(.white).font(.system(size: 20, weight: .bold)).lineSpacing(4).padding(.top, 10)
            Text(institution).foregroundColor(.amber).font(.system(size: 16)).padding(.top, 4)
            Text(subjects).foregroundColor(.white.opacity(0.6)).font(.system(size: 14)).lineSpacing(6).padding(.top, 8)
            Divider().background(Color.white.opacity(0.1)).padding(.top, 12)
        }
        .padding(.vertical, 12)
    }
}

// MARK: - Projects

struct ProjectsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Projects")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white.opacity(0.05))
            Text("My Projects")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)

            VStack(spacing: 12) {
                // TODO: Replace Color placeholders with Image("post2"), Image("post4"), Image("post5")
                ProjectCard(title: "AgentSelf - AI Digital Twin", category: "iOS App", height: 200)
                ProjectCard(title: "AgentShelf - AI Agent Showcase", category: "iOS & Android", height: 250)
                ProjectCard(title: "Portfolio Website", category: "Web Development", height: 200)
            }
            .padding(.top, 24)
        }
        .padding(20)
    }
}

struct ProjectCard: View {
    let title: String
    let category: String
    let height: CGFloat

    var body: some View {
        ZStack {
            // TODO: Replace with Image(imageName) when images are available
            LinearGradient(colors: [Color(white: 0.2), Color(white: 0.1)],
                          startPoint: .topLeading, endPoint: .bottomTrailing)

            VStack(spacing: 4) {
                Text(title).foregroundColor(.white).font(.system(size: 20, weight: .bold)).multilineTextAlignment(.center)
                Text(category).foregroundColor(.amber).font(.system(size: 14))
            }
        }
        .frame(height: height)
        .cornerRadius(8)
    }
}

// MARK: - Connect Me

struct ConnectMeSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Connect")
                .font(.system(size: 60, weight: .bold))
                .foregroundColor(.white.opacity(0.05))
            Text("Connect With Me")
                .font(.system(size: 32, weight: .bold))
                .foregroundColor(.white)
                .padding(.top, 4)

            HStack {
                Spacer()
                ConnectIcon(systemName: "person.fill", label: "LinkedIn", url: "https://www.linkedin.com/in/basavaprasad-gola/")
                Spacer()
                ConnectIcon(systemName: "star.fill", label: "Github", url: "https://github.com/prasadgola")
                Spacer()
                ConnectIcon(systemName: "arrowshape.turn.up.right.fill", label: "Twitter", url: "https://twitter.com/gola_basava")
                Spacer()
                ConnectIcon(systemName: "envelope.fill", label: "Instagram", url: "https://www.instagram.com/prasad_gola/")
                Spacer()
            }
            .padding(.top, 24)
        }
        .padding(20)
    }
}

struct ConnectIcon: View {
    let systemName: String
    let label: String
    let url: String

    var body: some View {
        Button(action: {
            if let url = URL(string: url) { UIApplication.shared.open(url) }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    Circle().fill(Color.white.opacity(0.1)).frame(width: 50, height: 50)
                    Image(systemName: systemName).foregroundColor(.amber).font(.system(size: 20))
                }
                Text(label).foregroundColor(.white.opacity(0.7)).font(.system(size: 12))
            }
        }
    }
}

// MARK: - Contact Form

struct ContactFormSection: View {
    @State private var name = ""
    @State private var email = ""
    @State private var subject = ""
    @State private var message = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ContactTextField(placeholder: "Your Name", text: $name)
            ContactTextField(placeholder: "Your Email", text: $email)
            ContactTextField(placeholder: "Subject", text: $subject)

            TextField("Message", text: $message, axis: .vertical)
                .lineLimit(5...10)
                .padding(12)
                .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.2), lineWidth: 1))
                .foregroundColor(.black)

            Button(action: { }) {
                Text("Send Message")
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.black)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(Color.amber)
                    .cornerRadius(4)
            }
            .padding(.top, 8)
        }
        .padding(20)
        .background(Color.white)
    }
}

struct ContactTextField: View {
    let placeholder: String
    @Binding var text: String

    var body: some View {
        TextField(placeholder, text: $text)
            .padding(12)
            .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.black.opacity(0.2), lineWidth: 1))
            .foregroundColor(.black)
    }
}
