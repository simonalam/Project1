# Multi-Level Page Table Implementation

A virtual memory address translation system using configurable multi-level page tables.

## Core Components

### Page Table Structure
- **Page Table Entry (PTE)**
  - Size: 8 bytes (size_t)
  - Format: 
    - Bit 0: Valid bit (1 = valid, 0 = invalid)
    - Bits 1-63: Physical page number (when valid)
  - Alignment: All page tables aligned to page size using posix_memalign

### Memory Layout
- Page Size: 2^POBITS bytes
- Page Table Size: 2^POBITS bytes
- Entries per Page Table: 2^(POBITS-3)
- Virtual Address Translation: LEVELS steps

### Key Functions

1. **translate(size_t va)**
   - Converts virtual to physical address
   - Returns ~0ULL if translation fails
   - Walks through page tables using valid bits
   - Time complexity: O(LEVELS)

2. **page_allocate(size_t va)**
   - Creates page table mapping for virtual address
   - Allocates new pages/tables as needed
   - Reuses existing page tables when possible
   - Time complexity: O(LEVELS)

## Configuration Guide (config.h)

### Parameter Selection

1. **LEVELS (1-6)**
   - Determines page table hierarchy depth
   - Choose based on address space needs:
     - 1-2: Small address spaces (< 2^32)
     - 3-4: Medium address spaces
     - 5-6: Large address spaces (up to 2^64)
   - Each level adds translation overhead

2. **POBITS (4-18)**
   - Controls page size (2^POBITS bytes)
   - Common configurations:
     - 12: 4KB pages (standard)
     - 16: 64KB pages
     - 18: 256KB pages
   - Larger pages reduce table size but increase fragmentation

### Configuration Constraints
- Must satisfy: (POBITS - 3) × (LEVELS + 1) ≤ 60
- Example valid configurations:
  - LEVELS=2, POBITS=12: Two-level paging with 4KB pages
  - LEVELS=3, POBITS=14: Three-level paging with 16KB pages

## Performance Analysis

### Time Complexity
- Translation: O(LEVELS) memory accesses
- Allocation: O(LEVELS) page table traversals
- Each level requires one memory access

### Space Complexity
- Per Page Table: 2^POBITS bytes
- Maximum Pages: 2^(POBITS × LEVELS)
- Total Space: O(2^POBITS × N), where N is allocated pages

## Memory Deallocation Proposal

### Proposed Interface
```c
void page_free(size_t va);