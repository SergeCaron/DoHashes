# Create/Verify hashes for a set of files

This utility computes hashes for all files in its current directory and  recursively does the same for its subdirectories. It will either:
- Create a "catalog" containing a hash and its corresponding filename for each file;
- Verify the hashes of all files in its current directory and identifies missing, new, and/or modified files.

The "catalog" is created in the directory containing the script. The intent is to distribute both the script and the "catalog" with whatever content is in this directory. No presumption is made regarding this content.

The script can be invoked with a right-click "Run with PowerShell". If the default "catalog" exists, the script prompts the user for the known signature. If none is provided, it will display the hash of the "catalog" and the user can copy/compare this value with the source of the files. In any case, the script pauses at the end to let the user review its output.

### Usage:
Where ...\ is the directory containing the files to hash:
````
...\DoHashes [-Algorithm xxx] [-CatalogName <filename>] <-KnownSignature <hash>]
````
Where:
- -Algorithm is the desired cryptographic hash function to use for computing the hash value of the files. Default is *SHA256*.
- -CatalogName is the file name of the "catalog" that is created or verified. Default is *Hashes.txt*.
- -KnownSignature is the hash of the "catalog" that will be validated. There is no default: this string is supplied by the provider of the files.

### Sample output for a directory containing the script and this ReadMe:
````
PS C:\Users\...> .\...\DoHashes.ps1
Hasher maker:
WARNING: Creating signatures ...
Catalogue signature:
**see note below**
Done.
Press enter to continue ...:
````

The hash value of the catalog cannot be shown here: by definition, this would change the hash of this ReadMe. You can find it *[here](https://github.com/SergeCaron/DoHashes/blob/d5b1ef777fb55d4486e8000f4b4cfd9ec8200a78/Resources/KnownSignature.txt)*.

The same goes for the hash values of the files which you can find *[here](https://github.com/SergeCaron/DoHashes/blob/b1f5c8df57e40f5f2724a53be4a5f319f5faad8f/Resources/Hashes.txt)*.


Integrity of the files can be verified with
````
PS C:\Users\...> .\...\DoHashes.ps1 -KnownSignature "**see note above**"
Hasher maker:
Catalogue signature verified in catalogue C:\Users\Usager\Desktop\SignatureChecker\\Hashes.txt
Done.
Press enter to continue...:
````
