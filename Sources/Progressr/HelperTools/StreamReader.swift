//
//  StreamReader.swift
//  Progressr
//
//  Created by Drew Hood on 3/2/17.
//
//

import Foundation

class StreamReader  {
    
    let encoding : String.Encoding
    let chunkSize : Int
    
    var fileHandle : FileHandle!
    var buffer : Data!
    let delimData : Data!
    var atEof : Bool = false
    
    init?(path: String, delimiter: String = "\n", encoding: String.Encoding = .utf8, chunkSize : Int = 4096) {
        self.chunkSize = chunkSize
        self.encoding = encoding
        
        if let fileHandle = FileHandle(forReadingAtPath: path),
            let delimData = delimiter.data(using: encoding)
        {
            self.fileHandle = fileHandle
            self.delimData = delimData
            self.buffer = Data(capacity: chunkSize)
        } else {
            self.fileHandle = nil
            self.delimData = nil
            self.buffer = nil
            return nil
        }
    }
    
    deinit {
        self.close()
    }
    
    /// Return next line, or nil on EOF.
    func nextLine() -> String? {
        precondition(fileHandle != nil, "Attempt to read from closed file")
        
        if atEof {
            return nil
        }
        
        // Read data chunks from file until a line delimiter is found:
        var range = buffer.range(of: delimData as Data, options: [], in: Range(uncheckedBounds: (0, buffer.endIndex)))
        while range == nil {
            let tmpData = fileHandle.readData(ofLength: self.chunkSize)
            if tmpData.count == 0 {
                // EOF or read error.
                atEof = true
                if buffer.count > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: self.buffer as Data, encoding: self.encoding)
                    
                    buffer.count = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: Range(uncheckedBounds: (0, buffer.endIndex)))
        }
        
        // Convert complete line (excluding the delimiter) to a string:
        var line = String(data: buffer.subdata(in: Range(uncheckedBounds: (0, range!.upperBound))), encoding: self.encoding)
        line = line?.replacingOccurrences(of: "\n", with: "")
        // Remove line (and the delimiter) from the buffer:
        buffer.removeSubrange(Range(uncheckedBounds: (0, range!.lowerBound + range!.count)))
        
        return line as String?
    }
    
    /// Start reading from the beginning of file.
    func rewind() -> Void {
        fileHandle.seek(toFileOffset: 0)
        buffer.count = 0
        atEof = false
    }
    
    /// Close the underlying file. No reading must be done after calling this method.
    func close() -> Void {
        fileHandle?.closeFile()
        fileHandle = nil
    }
}
