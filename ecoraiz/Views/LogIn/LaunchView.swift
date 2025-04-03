// En Views/Login/LaunchView.swift (O donde tengas tu vista inicial)

import SwiftUI

struct LaunchView: View {
    
    // --- Estados para la animación (Opcional) ---
    @State private var iconScale: CGFloat = 0.8
    @State private var textOpacity: Double = 0.0
    
    // --- Color Primario (Asegúrate que esté definido) ---
    // Si no, usa Color.green o el color que prefieras
    let primaryColor = Color.primaryGreen
    
    var body: some View {
        ZStack {
            // --- Fondo ---
            // Puedes usar un color sólido o un gradiente sutil
            primaryColor
                .ignoresSafeArea() // Cubre toda la pantalla
            
            // Alternativa: Gradiente
            /*
            LinearGradient(
                gradient: Gradient(colors: [primaryColor.opacity(0.8), primaryColor]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            */
            
            // --- Contenido Centrado ---
            VStack(spacing: 20) {
                Spacer() // Empuja al centro verticalmente (opción 1)
                
                // --- Logo ---
                Image("LIFI") // <-- USA EL NOMBRE DE TU ICONO/LOGO EN ASSETS
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400, height: 400) // Ajusta el tamaño según tu logo
                    .scaleEffect(iconScale) // Para animación opcional
                    .padding(.bottom, 10)
                
                Spacer() // Empuja al centro verticalmente (opción 1)
                
                // --- Indicador de Carga ---
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white)) // Estilo y color
                    .scaleEffect(1.5) // Hacerlo un poco más grande
                    .padding(.bottom, 50) // Espacio antes del borde inferior

            } // Fin VStack
        } // Fin ZStack
        .onAppear {
            // --- Animación Opcional al aparecer ---
            withAnimation(.easeInOut(duration: 0.6)) {
                iconScale = 1.0 // Escala el ícono a su tamaño normal
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.2)) {
                textOpacity = 1.0 // Hace aparecer el texto
            }
        }
    }
}

// --- Preview ---
#Preview {
    LaunchView()
}
