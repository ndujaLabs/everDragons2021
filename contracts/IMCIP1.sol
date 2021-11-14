// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @title IMCIP-1 On chain metadata
///  Version: 0.0.2
///  Note: the ERC-165 identifier for this interface is 0x0e32e192.
/* is ERC165 */
interface IMCIP1 {
  /// @dev This emits when the metadata for a token id are set.
  event MetadataSet(uint256 _tokenId, Metadata _metadata);

  /// @dev This struct saves info about the token. Some of the fields
  /// will be defined as mutable, some as immutable.
  /// The contract must implement a bytes32 variable that defines the mutability
  struct Metadata {
    // version must be immutable
    uint8 version;
    // status is mutable, it should be managed with bitwise operators
    uint8 status;
    // It supports a maximum of 8 properties. Here a list of the initial
    // values starting for the first digit on the right:
    //   bit name           value in bits and bytes1
    //   bridged              1               1
    //   transferable         1 << 1          2
    //   burnable             1 << 2          4
    // with the same approach used, for example, in chmod.
    // For example, if a token at a certain moment, is burnable and transferable
    // the value will be  (1 << 1) | (1 << 2)  => 6
    // If it is bridged and, by consequence, not transferable and not burnable, except
    // than by the bridge, it should be 7
    // If a token is set as not transferable or not burnable, the ERC721 hook
    // _beforeTokenTransfer must be overwritten accordingly.
    // The first bit from the right — bridged — is important becomes there are so
    // many bridges who move tokens around and it is almost impossible to
    // know if a token is bridged or not, i.e., if it is available on the market.

    // list of attributes
    uint8[30] attributes;
    // Unnecessary fields can be set to zero.
    // If, for example, a field requires more than 256 possible value, two bytes can be used for it.
  }

  /// @dev It returns the on-chain metadata of a specific token
  /// @param _tokenId The id of the token for whom to query the on-chain metadata
  /// @return The metadata of the token
  function metadataOf(uint256 _tokenId) external view returns (Metadata memory);

  /// @notice Retrieve the mutability of an attribute based on its index
  /// @dev It returns a boolean. Mutable: true, immutable: false.
  /// @param _tokenId The id of the token
  /// @param _attributeIndex The index of the attribute for whom to query the mutability
  /// @return The mutability
  function isAttributeMutable(uint256 _tokenId, uint8 _attributeIndex) external view returns (bool);

  /// @notice Sets the attributes of a token after first set up
  /// @dev Throws if the sender is not an operator authorized in the contract.
  /// Specifically, the sender must be a platform approved buy the NFT contract owner
  /// like, for example, a compatible game. Also, the token owner must approve the
  /// operator to spend their tokens (same function used in ERC721 for approvals).
  /// @param _tokenId The id of the token for whom to change the attributes
  /// @param _indexes The indexes of the attributes to be changed
  /// @param _values The values of the attributes to be changed
  /// @return true if the change is successful
  function updateAttributes(
    uint256 _tokenId,
    uint8[] memory _indexes,
    uint8[] memory _values
  ) external returns (bool);

  /// @notice Changes the status
  /// @dev Throws if the sender is not an operator authorized in the contract. See above.
  /// Same like above for the approval.
  /// @param _tokenId The id of the token for whom to change the attributes
  /// @param _shiftPosition The number of position to be left shifted
  /// For example, to change the transferability of token #12
  /// from 1 to 0, the operator contract should call
  ///    updateStatus(12, 1, 0);
  /// @param _newValue The bool must be converted in 1 or 0
  /// @return true if the change is successful
  function updateStatus(
    uint256 _tokenId,
    uint256 _shiftPosition,
    bool _newValue
  ) external returns (bool);
}
