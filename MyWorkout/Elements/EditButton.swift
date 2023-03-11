//
//  EditButton.swift
//  MyWorkout
//
//  Created by Ligmab Allz on 02/03/23.
//

import SwiftUI

struct EditButton: View {
    @Binding var editMode: EditMode
    
    var body: some View {
        Button(action: {
            if editMode == EditMode.active{
                editMode = EditMode.inactive
            }else{
                editMode = EditMode.active
            }
        }){
            if editMode == EditMode.active{
                Image(systemName: "checkmark.circle.fill")
                    .padding(.all, 2.0)
                    .background(Circle()
                        .foregroundColor(.green))
                
            }else{
                Image(systemName: "pencil.circle.fill")
                    .padding(.all, 2.0)
                    .background(Circle()
                        .foregroundColor(.blue))
            }
        }
        .shadow(color: Color.darkEnd.opacity(0.7), radius: 10, x: 10, y: 10)
        .shadow(color: Color.darkStart.opacity(1), radius: 10, x: -5, y: -5)
        .foregroundColor(.white)
        .font(.title2)
    }
}

struct EditButton_Previews: PreviewProvider {
    static var previews: some View {
        EditButton(editMode: .constant(EditMode.active))
    }
}
