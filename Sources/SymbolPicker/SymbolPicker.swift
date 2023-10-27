//
//  SymbolPicker.swift
//  SymbolPicker
//
//  Created by Yubo Qin on 2/14/22.
//

import SwiftUI

/// A simple and cross-platform SFSymbol picker for SwiftUI.
public struct SymbolPicker: View {
    // MARK: - Static consts

    private static var symbols: [String] {
        Symbols.shared.allSymbols
    }

    private static var gridDimension: CGFloat {
        #if os(iOS)
        return 64
        #elseif os(tvOS)
        return 128
        #elseif os(macOS)
        return 48
        #else
        return 48
        #endif
    }

    private static var symbolSize: CGFloat {
        #if os(iOS)
        return 24
        #elseif os(tvOS)
        return 48
        #elseif os(macOS)
        return 24
        #else
        return 24
        #endif
    }

    private static var symbolCornerRadius: CGFloat {
        #if os(iOS)
        return 8
        #elseif os(tvOS)
        return 12
        #elseif os(macOS)
        return 8
        #else
        return 8
        #endif
    }

    #if os(iOS)
    private let unselectedItemBackgroundColor: Color
    #else
    private let unselectedItemBackgroundColor: Color
    #endif

    #if os(tvOS)
    private let selectedItemBackgroundColor: Color
    #else
    private let selectedItemBackgroundColor: Color
    #endif

    #if os(iOS)
    private let backgroundColor: Color
    #else
    private let backgroundColor: Color
    #endif

    // MARK: - Properties

    @Binding public var symbol: String?
    @State private var searchText = ""
    @Environment(\.dismiss) private var dismiss

    private let nullable: Bool

    // MARK: - Public Init

    /// Initializes `SymbolPicker` with a string binding that captures the raw value of
    /// user-selected SFSymbol.
    /// - Parameter symbol: String binding to store user selection.
    public init(
        symbol: Binding<String>,
        backgroundColor: Color? = nil,
        selectedItemBackgroundColor: Color? = nil,
        unselectedItemBackgroundColor: Color? = nil
    ) {
        _symbol = Binding {
            symbol.wrappedValue
        } set: { newValue in
            /// As the `nullable` is set to `false`, this can not be `nil`
            if let newValue {
                symbol.wrappedValue = newValue
            }
        }
        nullable = false

        if let backgroundColor {
            self.backgroundColor = backgroundColor
        } else {
            #if os(iOS)
            self.backgroundColor = .init(UIColor.systemGroupedBackground)
            #else
            self.backgroundColor = .clear
            #endif
        }

        if let selectedItemBackgroundColor {
            self.selectedItemBackgroundColor = selectedItemBackgroundColor
        } else {
            #if os(tvOS)
            self.selectedItemBackgroundColor = .gray.opacity(0.3)
            #else
            self.selectedItemBackgroundColor = .accentColor
            #endif
        }

        if let unselectedItemBackgroundColor {
            self.unselectedItemBackgroundColor = unselectedItemBackgroundColor
        } else {
            #if os(iOS)
            self.unselectedItemBackgroundColor = .init(UIColor.systemBackground)
            #else
            self.unselectedItemBackgroundColor = .clear
            #endif
        }
    }

    /// Initializes `SymbolPicker` with a nullable string binding that captures the raw value of
    /// user-selected SFSymbol. `nil` if no symbol is selected.
    /// - Parameter symbol: Optional string binding to store user selection.
    public init(
        symbol: Binding<String?>,
        backgroundColor: Color? = nil,
        selectedItemBackgroundColor: Color? = nil,
        unselectedItemBackgroundColor: Color? = nil
    ) {
        _symbol = symbol
        nullable = true

        if let backgroundColor {
            self.backgroundColor = backgroundColor
        } else {
            #if os(iOS)
            self.backgroundColor = .init(UIColor.systemGroupedBackground)
            #else
            self.backgroundColor = .clear
            #endif
        }

        if let selectedItemBackgroundColor {
            self.selectedItemBackgroundColor = selectedItemBackgroundColor
        } else {
            #if os(tvOS)
            self.selectedItemBackgroundColor = .gray.opacity(0.3)
            #else
            self.selectedItemBackgroundColor = .accentColor
            #endif
        }

        if let unselectedItemBackgroundColor {
            self.unselectedItemBackgroundColor = unselectedItemBackgroundColor
        } else {
            #if os(iOS)
            self.unselectedItemBackgroundColor = .init(UIColor.systemBackground)
            #else
            self.unselectedItemBackgroundColor = .clear
            #endif
        }
    }

    // MARK: - View Components

    @ViewBuilder
    private var searchableSymbolGrid: some View {
        #if os(iOS)
        symbolGrid
            .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always))
        #elseif os(tvOS)
        VStack {
            TextField(LocalizedString("search_placeholder"), text: $searchText)
                .padding(.horizontal, 8)
                .autocapitalization(.none)
                .disableAutocorrection(true)
            symbolGrid
        }

        /// `searchable` is crashing on tvOS 16. What the hell aPPLE?
        ///
        /// symbolGrid
        ///     .searchable(text: $searchText, placement: .automatic)
        #elseif os(macOS)
        VStack(spacing: 0) {
            HStack {
                TextField(LocalizedString("search_placeholder"), text: $searchText)
                    .textFieldStyle(.plain)
                    .font(.system(size: 18.0))
                    .disableAutocorrection(true)

                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 16.0, height: 16.0)
                }
                .buttonStyle(.borderless)
            }
            .padding()

            Divider()

            symbolGrid

            if canDeleteIcon {
                Divider()
                HStack {
                    Spacer()
                    deleteButton
                        .padding(.horizontal)
                        .padding(.vertical, 8.0)
                }
            }
        }
        #else
        symbolGrid
            .searchable(text: $searchText, placement: .automatic)
        #endif
    }

    private var symbolGrid: some View {
        ScrollView {
            #if os(tvOS) || os(watchOS)
            if canDeleteIcon {
                deleteButton
            }
            #endif

            LazyVGrid(columns: [GridItem(.adaptive(minimum: Self.gridDimension, maximum: Self.gridDimension))]) {
                ForEach(Self.symbols.filter { searchText.isEmpty ? true : $0.localizedCaseInsensitiveContains(searchText) }, id: \.self) { thisSymbol in
                    Button {
                        symbol = thisSymbol
                        dismiss()
                    } label: {
                        if thisSymbol == symbol {
                            Image(systemName: thisSymbol)
                                .font(.system(size: Self.symbolSize))
                            #if os(tvOS)
                                .frame(minWidth: Self.gridDimension, minHeight: Self.gridDimension)
                            #else
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                            #endif
                                .background(selectedItemBackgroundColor)
                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.white)
                        } else {
                            Image(systemName: thisSymbol)
                                .font(.system(size: Self.symbolSize))
                                .frame(maxWidth: .infinity, minHeight: Self.gridDimension)
                                .background(unselectedItemBackgroundColor)
                                .cornerRadius(Self.symbolCornerRadius)
                                .foregroundColor(.primary)
                        }
                    }
                    .buttonStyle(.plain)
                    #if os(iOS)
                        .hoverEffect(.lift)
                    #endif
                }
            }
            .padding(.horizontal)

            #if os(iOS)
            /// Avoid last row being hidden.
            if canDeleteIcon {
                Spacer()
                    .frame(height: Self.gridDimension * 2)
            }
            #endif
        }
    }

    private var deleteButton: some View {
        Button(role: .destructive) {
            symbol = nil
            dismiss()
        } label: {
            Label(LocalizedString("remove_symbol"), systemImage: "trash")
            #if !os(tvOS) && !os(macOS)
                .frame(maxWidth: .infinity)
            #endif
            #if !os(watchOS)
            .padding(.vertical, 12.0)
            #endif
            .background(unselectedItemBackgroundColor)
            .clipShape(RoundedRectangle(cornerRadius: 12.0, style: .continuous))
        }
    }

    public var body: some View {
        #if !os(macOS)
        NavigationView {
            ZStack {
                #if os(iOS)
                backgroundColor.edgesIgnoringSafeArea(.all)
                #endif
                searchableSymbolGrid

                #if os(iOS)
                if canDeleteIcon {
                    VStack {
                        Spacer()

                        deleteButton
                            .padding()
                            .background(.regularMaterial)
                    }
                }
                #endif
            }
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            #if !os(tvOS)
            /// tvOS can use back button on remote
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(LocalizedString("cancel")) {
                        dismiss()
                    }
                }
            }
            #endif
        }
        .navigationViewStyle(.stack)
        #else
        searchableSymbolGrid
            .frame(width: 540, height: 340, alignment: .center)
            .background(.regularMaterial)
        #endif
    }

    private var canDeleteIcon: Bool {
        nullable && symbol != nil
    }
}

private func LocalizedString(_ key: String) -> String {
    NSLocalizedString(key, bundle: .module, comment: "")
}

struct SymbolPicker_Previews: PreviewProvider {
    @State static var symbol: String? = "square.and.arrow.up"

    static var previews: some View {
        Group {
            SymbolPicker(symbol: Self.$symbol)
            SymbolPicker(symbol: Self.$symbol)
                .preferredColorScheme(.dark)
        }
    }
}
